CREATE PROCEDURE [dbo].[COM_SET_TURN] (@UserID int)
AS
BEGIN
set nocount on

declare @wturn int
declare @emplID int 
declare @today date 
declare @now datetime

select @emplID = A.EMPLOYEEID from DEF_USERS A with(nolock) where A.ID = @UserID

set @now = getdate()
set @today = cast(@now as date) 

select @wturn = A.WTURN
from COM_TURNS A with (nolock)
where A.EMPLID = @emplID
  and A.DD = @today

declare @wtID int
select @wtID = ISNULL(A.PERSONALWT,B.ID)
from COM_EMPLOYEE A with (nolock) 
left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
where A.ID = @emplID

declare @turnsCount int
select @turnsCount = count(distinct A.WTURN)
from COM_WORKTIME_BR A with (nolock)
where A.VNESHID = @wtID

if isnull(@turnsCount,0) = 0
begin
  set nocount off
  return
end  


if @wturn is not null and not exists (select KK.ID from COM_WORKTIME_BR KK with(nolock) where KK.VNESHID = @wtID and isnull(KK.TDEXTDAY,0) = 2)
begin
  set nocount off
  return
end  



if @turnsCount > 1
begin
  /* если есть установленная действующая смена ( в т.ч. вчерашняя), то выходим
     +2 часа после окончания действующей смены чтобы не получалось
     что при случайном входе (или переработке?) через 2 минуты после окончания ночной смены 
     устанавливалась первая смена следующего рабочего дня
     насколько надежно в реальности будет работать этот механизм в режиме "24" - ?
  */
  if exists (select * 
               from dbo.COM_TURNS_AROUND(@now,@wtID,@emplID) 
               where ACTIVATEDWTURN =1 
                 and @now >= WTURNBEG 
                 and @now <= dateadd(hour,2,WTURNEND)
             )
	begin
	  set nocount off
	  return
	end  

  /*KB3492 смысл такой-же как в предыдущем, но условие такое: 
    если в районе окончания действующей смены +-2часа была запись о
    переработке, которая еще не кончилась (либо после окончания не прошло 30 минут)
    то не устанавливать смену сл. рабочего дня*/
  if exists (select * 
               from dbo.COM_TURNS_AROUND(@now,@wtID,@emplID) A
               where A.ACTIVATEDWTURN =1 
                 and @now >= A.WTURNBEG 
                 and @now <= dateadd(hour,8,A.WTURNEND)
                 and exists (select * from COM_ADDED_WORKTIME K with(nolock)
						  where K.EMPLID = @emplID 
							and abs(datediff(hour,K.DBEG,A.WTURNEND)) < 2
							and dateadd(minute,30,K.DEND) > @now
						 )
             )
	begin
	  set nocount off
	  return
	end  

             
   
  /* принцип поиска смены - ищем ближайшую (с обеих сторон) смену по началу смены */
  
  declare @wturn_need int
  declare @workday date

  select top 1 @wturn_need = WTURN, @workday = WORKDAY
  from dbo.COM_TURNS_AROUND(@now,@wtID,@emplID) 
  order by DIFFABS
  
  if @wturn_need is not null and @workday is not null
  begin
      if not exists (select J.ID from COM_TURNS J where J.EMPLID = @emplID and J.DD = @workday)
      begin
		insert into COM_TURNS (S_CR,S_CDT,EMPLID,DD,WTURN)
		values (@UserID,@now,@emplID,@workday,@wturn_need)
	  end	
  end
  
  
end
  
set nocount off
END