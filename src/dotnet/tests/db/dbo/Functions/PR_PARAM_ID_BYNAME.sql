create function [dbo].[PR_PARAM_ID_BYNAME](@ModelTypeID int, @ParamName nvarchar(300))
returns int as 
begin


  declare @ParamID int

  select top 1 @ParamID = A.ID
  from PR_MODELTYPE_PARAMS A with (nolock)
  where A.TYPEID = @ModelTypeID
    and A.NAME = @ParamName
    
  return @ParamID

end