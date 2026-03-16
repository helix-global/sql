create function [dbo].[WEB_IS_PARAM_INDEXED] (@ModelTypeName nvarchar(300), @ParamName nvarchar(300))
returns int
as 
begin
 
  declare @PrmID int
  select top 1 @PrmID = B.ID
  from PR_MODELTYPE A with (nolock)
  left join PR_MODELTYPE_PARAMS B with (nolock) on B.TYPEID = A.ID
  where A.NAME = @ModelTypeName 
    and B.NAME = @ParamName
 
  if @PrmID is null
    return 0 
 
  if exists (select C.ID from PR_IMP_INDEX_PRMS C with (nolock) where C.PRMID = @PrmID)
    return 1 
 
  return 0

end