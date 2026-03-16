-- KB5391:2025-04-28: Using [PM_TASK_TIME].[MINUTES] if it available.
CREATE FUNCTION [dbo].[PM_TASK_TIMESUM_BYEMPL](@TaskID int,@EmplID int,@Mode int)
returns decimal(10,2)
as
begin
  declare @r decimal(10,2)
  select
    @r = sum(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)
  from [dbo].[PM_TASK_TIME] [a] with(nolock)
  where [a].[TASKID]= @TaskID
    and [a].[EMPLID]= @EmplID
  return @r/60.0
end