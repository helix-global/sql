create PROCEDURE [dbo].[COM_SET_TURN_old] (@UserID int)
AS
BEGIN
set nocount on

declare @wturn int
declare @emplID int 
declare @today date 
declare @now datetime

set @now = getdate()
set @today = cast(@now as date) 

if datepart(hour,@now) < 3
   set @today = dateadd(day,-1,@today)


select @emplID = A.EMPLOYEEID from DEF_USERS A where A.ID = @UserID

select @wturn = A.WTURN
from COM_TURNS A with (nolock)
where A.EMPLID = @emplID
  and A.DD = @today

if @wturn is not null
begin
  set nocount off
  return
end  

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

if @turnsCount > 1
begin
  
  declare @wturn_need int
  select top 1 @wturn_need = A.WTURN
  from dbo.COM_WTURNS_BEGINS(@wtID,0) A
  order by ABS(DATEDIFF(minute,A.TFROM,cast(getdate() as time)))
  
  if @wturn_need is not null
  begin
	  insert into COM_TURNS (S_CR,S_CDT,EMPLID,DD,WTURN)
	  values (@UserID,@now,@emplID,@today,@wturn_need)
  end
  
  
end
  
set nocount off
END