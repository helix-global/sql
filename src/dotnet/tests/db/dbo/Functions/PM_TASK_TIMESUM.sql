-- KB5391:2025-04-28: Using [PM_TASK_TIME].[MINUTES] if it available.
CREATE FUNCTION [dbo].[PM_TASK_TIMESUM](@TaskID int, @Mode int)
RETURNS decimal(10,2)
as
begin
  declare @r decimal(10,2) = 0
  /*
  @Mode = 1 - только по задаче
  @Mode = 2 - по задаче + по дочерним
  +KB2974
  @Mode = 5 - только по дочерним
  */
  if isnull(@Mode,0) <> 5
  begin
    select
      @r = sum(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)
    from [dbo].[PM_TASK_TIME] [a] with(nolock)
    where [a].[TASKID]=@TaskID
  end
  if @Mode in (2,5)
  begin
    declare @childres decimal(10,2)
    select
      @childres = sum(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)
    from [PM_TASK_TIME] [a] with(nolock)
    where [a].[TASKID] in (select [ID] from [dbo].[PM_GET_CHILD_TASKS](@TaskID,0))
    set @r = @r + isnull(@childres,0)
  end
  return @r/60.0
END