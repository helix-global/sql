--KB5377: Using [PM_TASK_TIME].[MINUTES] if it available.
CREATE FUNCTION [dbo].[PM_TIMETRACK_SUMDAY](@EmplID int,@Date date,@Mode int)
returns decimal(10,2)
as
begin
  declare @r decimal(10,2)
  select
    @r = sum(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)
  from [dbo].[PM_TASK_TIME] [a] with(nolock)
  where [a].[EMPLID]=@EmplID
    and [a].[DD]=@Date
  return @r/60.0
end