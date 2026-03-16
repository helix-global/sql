create FUNCTION [dbo].[PR_PN_DESC_BY_CODE]
(
	@PartNumberCode nvarchar(50)
)
RETURNS nvarchar(250)
AS
BEGIN
  
  declare @res nvarchar(250)
  
  select @res = A.DESCSTR from PR_NAV_PN_CACHE A with (nolock) where A.CODE = @PartNumberCode
  
  if (@res is null)
    select @res = A.DESCSTR from PR_MODELS A with (nolock) where A.CODE = @PartNumberCode
  
  return @res;

END