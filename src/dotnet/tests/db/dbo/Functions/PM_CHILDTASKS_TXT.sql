CREATE FUNCTION [dbo].[PM_CHILDTASKS_TXT](@TaskID int, @UserID int, @mode int)
RETURNS nvarchar(max)
AS
BEGIN
  declare @res nvarchar(max)
  
  select @res = isnull(@res,'') + A.SUBJ + char(13)+char(10)
  from PM_TASK A with (nolock)
  where A.PARENTID = @TaskID
    and A.SUBJ is not null
    and (isnull(@mode,0) <> 1 or A.S_S not in (2130052,2130066,2130067))
  
  return @res

END