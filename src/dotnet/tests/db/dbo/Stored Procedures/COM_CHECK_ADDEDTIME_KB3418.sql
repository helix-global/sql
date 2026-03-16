CREATE PROCEDURE [dbo].[COM_CHECK_ADDEDTIME_KB3418] (@emplID int, @dbeg datetime)
AS
BEGIN
set nocount on

/*KB3418 p.3 :

   ...проверку на создание переработок таким образом, чтобы нельзя было создать овертайм перед рабочей сменой,
    если от окончания предыдущей смены (включая овертаймы после предыдущей рабочей смены) не прошло 11 часов. 
    Нужно выдавать ошибку в таком случае "11 hours must be passed from the end of the previous day's work". 

*/

declare @wtID int
  
select @wtID = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@emplID,@dbeg)

/* 1. вообще есть смены в графике*/
declare @turnsCount int
select @turnsCount = count(distinct isnull(A.WTURN,1))
from COM_WORKTIME_BR A with(nolock)
where A.VNESHID = @wtID

if @turnsCount < 2
begin
  set nocount off
  return
end

/* 2. Конец "предыдущей" смены - что это? 
?Максимальное время окончания одной из смен в истории если это время(окончания) уже прошло? 
?причем после этой смены должна быть другая смена, время окончания которой еще не прошло?
(иначе получится что нельзя создать переработку сразу после окончившейся смены)
*/

declare @endOfPreviousTurn datetime

select @endOfPreviousTurn = max(M.WTURNEND)
from (
  select B.WTURNEND
  from dbo.COM_TURNS_AROUND(@dbeg,@wtID,@emplID) B 
  where B.ACTIVATEDWTURN = 1
    and B.WTURNEND <= @dbeg
    and exists(select K.ID
                 from COM_TURNS K with(nolock)
                 where K.EMPLID = @emplID
                   and K.DD > B.WORKDAY
               )     
)M


if @endOfPreviousTurn is null
begin
  set nocount off
  return
end

/*KB3937 -> */
declare @correctedEndOfPreviousTurn datetime

;with allperiods as (
select dbo.COM_VACATION_DBEG3(A.ID) as dbeg
  ,dbo.COM_VACATION_DEND3(A.ID) as dend
from COM_VACATION A with(nolock) 
where A.EMPLID = @emplID 
  and A.S_S in (1000141,2130051)  /*approved,submitted*/
  and isnull(A.DEND,A.DBEG) > dateadd(day,-1,@endOfPreviousTurn)
  and isnull(A.DEND,A.DBEG) < dateadd(day,1,@endOfPreviousTurn)
)
,mergedperiods /* объединение периодов отсутствий, которые идут подряд (10:15-10:30,10:30-11:20) или пересекаются, но насколько такое реально ???*/ 
 as ( 
   select dbeg , dend
    from 
   ( select min(dbeg) as dbeg, row_number() over(order by min(dbeg)) as rn
       from allperiods s1
      where not exists (select 1 from allperiods s2 where s2.dbeg < s1.dbeg and s2.dend >= s1.dbeg)
	  group by dbeg
   ) v_begin,
   ( select min(dend) as dend, row_number() over(order by min(dend)) as rn
       from allperiods s1
      where not exists (select null from allperiods s2 where s2.dend > s1.dend and s2.dbeg <= s1.dend)
	  group by dend
   ) v_end
   where v_begin.rn = v_end.rn
  )  
select @correctedEndOfPreviousTurn = max(dbeg) from mergedperiods
where @endOfPreviousTurn <= dend
  and @endOfPreviousTurn > dbeg
  
if @correctedEndOfPreviousTurn is not null and datediff(hour,@correctedEndOfPreviousTurn,@endOfPreviousTurn) <= 11 and @correctedEndOfPreviousTurn < @endOfPreviousTurn
begin
  set @endOfPreviousTurn = @correctedEndOfPreviousTurn
end 
/* <- KB3937*/


/* 3. переработки после @endOfPreviousTurn - ? насколько "после" ? */

declare @endOfOvertimes datetime
select @endOfOvertimes = max(A.DEND)
from COM_ADDED_WORKTIME A with(nolock)
where A.EMPLID = @emplID
  and A.DEND > @endOfPreviousTurn
  and abs(datediff(minute,A.DBEG,@endOfPreviousTurn)) <= 120 /* доработка создана +-2 часа от окончания смены */ 
/*? а если после первой переработки будет еще одна или несколько, но уже дальше чем на 2 часа от смены ?*/

declare @diff int = datediff(minute,isnull(@endOfOvertimes,@endOfPreviousTurn),@dbeg)
if @diff < 660
begin
	--raiserror('#E11 hours must be passed from the end of the previous day`s work',16,1) --KB3535 instead error need to check if next turns is already passed/worked

	/* KB3535 */
	-- check if has next turn and it is already worked
	declare @startOfNextTurn datetime
	select @startOfNextTurn = min(M.WTURNBEG)
		from (
		  select B.WTURNBEG
		  from dbo.COM_TURNS_TOMORROW(@dbeg,@wtID,@emplID) B 
		  where B.ACTIVATEDWTURN = 1
		    and B.WTURNBEG >= @dbeg
		    and exists(select K.ID
		                 from COM_TURNS K with(nolock)
		                 where K.EMPLID = @emplID
		                   and K.DD > B.WORKDAY
		               )     
		)M
	
	
	if @startOfNextTurn is null 
	-- if don have turn after planning overtime then error	
	begin 
	    if @diff > 0   /*временно т.к. по-хорошему тут все нужно переписывать см. KB4144 */
	    begin
			raiserror('#E11 hours must be passed from the end of the previous day`s work',16,1)
		end	
	end
	else
	begin 
		-- chek diff betwin start next turn and end overtime > 11 hours (660 vby)
		if datediff(minute,isnull(@endOfOvertimes,@endOfPreviousTurn),@startOfNextTurn) < 660
		begin
			raiserror('#E11 hours must be passed from the end of the previous day`s work!',16,1)
		end
	end
	/* KB3535 */



end
  
set nocount off
END