create function [dbo].[PR_REVISION_PARAM_FLOAT](@RevisionID int, @ParamID int)
returns float as 
begin
  declare @val sql_variant
  set @val = dbo.PR_REVISION_PARAM(@RevisionID, @ParamID)
  if @val is null
    return null
    
  declare @valstr varchar(200)
  set @valstr = CAST(@val as varchar(200))
  set @valstr = REPLACE(@valstr,',','.')
  
  if isnumeric(@valstr) = 1
     return cast(@valstr as float);
  
  return null
  
end