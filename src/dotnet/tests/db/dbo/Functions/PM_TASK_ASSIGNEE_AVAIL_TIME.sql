CREATE FUNCTION [dbo].[PM_TASK_ASSIGNEE_AVAIL_TIME](@TaskID int, @ToDate datetime, @mode int)
RETURNS decimal(10,2)
AS
BEGIN
  
  declare @now datetime = getdate()
  declare @nowD datetime 
  set @nowD = cast(@now as date)
  
  declare @res decimal(10,2)

  select @res = sum(dbo.COM_ATTENDANCE_TIME2(null,A.EMPLID,B.DDATE))
  from PM_TASK_ASSIGNEE A with (nolock)
  cross apply dbo.COM_DAY_PERIOD(@nowD,@ToDate) B
  where A.VNESHID = @TaskID


  return @res 

END