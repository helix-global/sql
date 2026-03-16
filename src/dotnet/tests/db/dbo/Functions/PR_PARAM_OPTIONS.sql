create function [dbo].[PR_PARAM_OPTIONS](@aParamID int, @aModeID int)
returns nvarchar(max) as 
begin

  declare @res nvarchar(max)
  if exists (select B.ID from PR_DOC_SETTINGS B with (nolock) where B.PARAMID = @aParamID)
    set @res = 'Used in Declarations of Conformity'
  
  return @res  

end