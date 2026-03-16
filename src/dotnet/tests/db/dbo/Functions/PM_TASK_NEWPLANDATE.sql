create FUNCTION [dbo].[PM_TASK_NEWPLANDATE](@oldDate datetime, @PlanID int, @TaskID int, @mode int)
RETURNS datetime
AS
BEGIN
  /*KB3554  п.4 */
  
  declare @res datetime     
  declare @res2 datetime     
  
  select @res = (select max(J.DD) from PM_DEV_PLAN_T_T J with(nolock)   
				  where J.VNESHID = A.ID and J.MHOUR <> 0)
  from PM_DEV_PLAN_T A with(nolock)
  where A.VNESHID = @PlanID
    and A.TASKID = @TaskID
    and A.LABOR_EST is not null
    and A.LABOR_EST <> 0
    and (select count(distinct LL.EMPLID) from PM_TASK_ASSIGNEE LL with(nolock) where LL.VNESHID = @TaskID) = 1
  
 
  if exists (select B.ID from PM_TASK B with(nolock) where B.PARENTID = @TaskID)
  begin
  
	select @res2 = max(DD) 
	from (
	  select @res as DD
	  union 
	  select A.PLANDATE from PM_TASK A with(nolock) where A.ID in (select ID from dbo.PM_GET_CHILD_TASKS(@TaskID,0))
	)M  
  
  end    
  
  return coalesce(@res2,@res,@oldDate)

END