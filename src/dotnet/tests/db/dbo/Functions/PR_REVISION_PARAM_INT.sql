create function [dbo].[PR_REVISION_PARAM_INT](@RevisionID int, @ParamID int)
returns int as 
begin
  declare @val sql_variant
  set @val = dbo.PR_REVISION_PARAM(@RevisionID, @ParamID)
  if @val is null
    return null
  return cast(@val as int)
end