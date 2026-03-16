create FUNCTION [dbo].[PM_TASK_PREDECESSORS](@TaskID int, @aProjID int, @mode int)
RETURNS nvarchar(max)
AS
BEGIN
  declare @res nvarchar(max)
  
  select @res = isnull(@res,'') + cast(B.ID as nvarchar(20)) + ' '
  from PM_TASK_DEPEND A with (nolock)
  left join PM_TASK B with (nolock) on B.ID = A.VNESHID 
  where A.TOTASKID = @TaskID
    and B.PROJID = @aProjID
  
  
  return @res

END