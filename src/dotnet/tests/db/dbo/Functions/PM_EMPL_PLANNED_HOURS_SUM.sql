CREATE FUNCTION [dbo].[PM_EMPL_PLANNED_HOURS_SUM](@EmplID int, @FromDate datetime, @ToDate datetime, @mode int)
RETURNS decimal(10,2)
AS
BEGIN
  
  declare @res decimal(10,2)

  select @res = sum(F.MHOUR)
  from PM_TASK_ASSIGNEE A with (nolock)
  left join PM_TASK B with (nolock) on B.ID = A.VNESHID
  left join PM_DEV_PLAN_T_T F with (nolock) on F.VNESHID = B.LASTPLAN_ROWID
  where A.EMPLID = @EmplID
    and F.DD >= @FromDate
    and F.DD <= @ToDate    
  

  return isnull(@res,0) 

END