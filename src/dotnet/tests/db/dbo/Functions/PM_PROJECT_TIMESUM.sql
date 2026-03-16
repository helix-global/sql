-- KB5391:2025-04-28: Using [PM_TASK_TIME].[MINUTES] if it available.
CREATE FUNCTION [dbo].[PM_PROJECT_TIMESUM](@ProjectID int,@Mode int)
RETURNS decimal(10,2)
AS
BEGIN
  declare @r decimal(10,2)
  select
    @r = sum(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)
  from [dbo].[PM_TASK_TIME] [a] with(nolock)
  where [a].[TASKID] in (select [ID] from [PM_TASK] with(nolock) where [PROJID]=@ProjectID)
  return @r/60.0
END