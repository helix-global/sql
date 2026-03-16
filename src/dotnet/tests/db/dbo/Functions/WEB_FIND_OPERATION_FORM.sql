CREATE FUNCTION [dbo].[WEB_FIND_OPERATION_FORM](@UserID int, @ModelTypeName nvarchar(300), @OperationFormCode nvarchar(50))
RETURNS int
AS
BEGIN
  
  declare @res int
  
  select top(1) @res=O.ID 
  from PR_OPERATIONS O with(nolock)
  left join PR_MODELTYPE T with(nolock) on O.MTID = T.ID
  where O.ID in (select GG.ID from dbo.PR_OPERS_DEP_ACCESS_TAB(8,@UserID,getdate()) GG)
    and T.NAME=@ModelTypeName
    and O.CODE=@OperationFormCode
  
  return @res;

END