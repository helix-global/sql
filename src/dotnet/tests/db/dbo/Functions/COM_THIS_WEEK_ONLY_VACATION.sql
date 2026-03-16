CREATE function [dbo].[COM_THIS_WEEK_ONLY_VACATION](@emplid int, @now datetime)
returns int
as 
begin

/* возвращает 1 если все следующие дни в недели выходные и текущий день уже закончен*/

declare @wtID int
declare @Calendar int

select @wtID = ISNULL(A.PERSONALWT,B.ID), @Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
from COM_EMPLOYEE A with (nolock) 
left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
where A.ID = @emplid


/* 1. если есть рабочий день дальше в этой неделе > @now => вернуть 0 */
if exists (
		select A.WEEKDD 
		from dbo.COM_WEEK_EMPL_WORKTIME(@now,@emplid) A
		where A.WEEKDD > @now
		  and dbo.COM_IS_WORKDAY2(A.WEEKDD,@Calendar,@wtID) = 1
		  and A.VACATIONDAY = 0
		)
		return 0
	
/* 2. сегодня (@now2) уже закончен => вернуть 1 */		
declare @now2 datetime = getdate()  /*тот что @now в параметре без времени*/
/*
declare @nowFixed datetime = @now
if datepart(hour,@now2) < 3  /*KB2026 если от 0:00 до 2:59 часов, то это вторая смена и окончание рабочего дня нужно искать по предыдущему дню */
  set @nowFixed = dateadd(hour,-3,@nowFixed)
*/

declare @workDayEnd datetime
/*select @workDayEnd = max(DEND) from dbo.COM_WORKPERIODS5(@nowFixed,dateadd(day,1,@nowFixed),@Calendar,@wtID,@emplid)*/ 
/*KB3228*/
select top 1 @workDayEnd = A.WTURNEND from dbo.COM_TURNS_AROUND(@now2,@wtID,@emplid) A
where (A.ACTIVATEDWTURN =1 or A.ONLYONEWTURN =1)
  and A.ISWORKDAYOFWEEK = 1
order by A.DIFFABS_END

if @now2 > @workDayEnd
  return 1
  
/*если между @now2 и @workDayEnd только утвержденные короткие отсутствия - вернуть 1*/  
if dbo.COM_ONLY_SHORTABS_BETWEEN(@emplid,@now2,@workDayEnd,0) = 1
   return 1

/*KB3409 день заканчивается раньше из-за отсутсвия afternoon*/
if exists (select A.ID 
             from COM_VACATION A with(nolock) 
            where A.EMPLID = @emplid 
              and A.S_S in (1000141,2130051) /*Approved*/
              and cast(A.DBEG as date) = cast(@now2 as date)
              and A.PERIODTYPE = 3)
begin
   declare @workDayEndIfAbsence datetime
   select @workDayEndIfAbsence = max(DEND)
   from dbo.COM_REAL_WORKPERIODS2(cast(@now2 as date),dateadd(day,1,cast(@now2 as date)),@Calendar,@wtID,@emplid)
   if @workDayEndIfAbsence is not null and cast(@workDayEndIfAbsence as date) = cast(@now2 as date) 
   begin
		if @workDayEndIfAbsence < @workDayEnd and @now2 > @workDayEndIfAbsence
			return 1
   end    
end             

		
return 0
    
end