CREATE FUNCTION [dbo].[PR_PN_NAME_BY_CODE]
(
	@PartNumberCode nvarchar(50)
)
RETURNS nvarchar(250)
AS
BEGIN
  
  declare @res nvarchar(250)
  
  select @res = A.NAME from PR_NAV_PN_CACHE A with (nolock) where A.CODE = @PartNumberCode
  
  if (@res is null)
    select @res = A.NAME from PR_MODELS A with (nolock) where A.CODE = @PartNumberCode
  
  return @res;

END