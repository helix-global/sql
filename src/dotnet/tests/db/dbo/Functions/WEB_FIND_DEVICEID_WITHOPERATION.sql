CREATE FUNCTION [dbo].[WEB_FIND_DEVICEID_WITHOPERATION](@UserID int, @aCode nvarchar(16), @aSN nvarchar(50))
RETURNS int
AS
BEGIN
  
  declare @res int
  
  select @res = B.ID
  from PR_OPERATION A with (nolock) 
  left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID 
  left join PR_MODELS C with (nolock) on C.ID = B.MODELID 
  where C.CODE like @aCode
    and B.SN = @aSN
    and A.ID in (select G.ID from dbo.PR_IS_MY_CO_NEW(@UserID,getdate()) G)
    and C.DEPID <> 222 /* (IPGP Packaging) диодные модули часто совпадают по серийным номерам, а утилиты LDM не могут фильтровать по модели  */

  
  return @res;

END