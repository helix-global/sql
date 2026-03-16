CREATE function [dbo].PRR_KB3327_OPERATIONS_LIST(@aEmplID int,@aYY int,@aMM int,@aDD int)
returns @res table (ID int) as 
begin


  declare @ddd date = dbo.COM_ENCODE_DATE(@aYY,@aMM,@aDD)
  declare @ddde datetime = @ddd
  
  set @ddde = dateadd(hour,27,@ddde) 
  
  declare @wtid int = dbo.COM_WORKTABLE_BY_DATE2(@ddd,@aEmplID)
  declare @Calendar int
  select @Calendar = A.CALENDAR from COM_WORKTIME A with (nolock) where A.ID = @wtID 
  
  declare @ddde2 datetime
  select @ddde2 = max(DEND) 
  from dbo.COM_WORKPERIODS3(@ddd,@ddde,@Calendar,@wtid,@aEmplID)
  
  set @ddde = isnull(@ddde2,@ddde)
  
  insert into @res (ID)
  select A.OPERID 
  from PR_OPERATION_TIME A with(nolock)
  where A.EMPID = @aEmplID
    and A.DBEG <= @ddde
    and isnull(A.DEND,A.DBEG) >= @ddd 
  
  return

end