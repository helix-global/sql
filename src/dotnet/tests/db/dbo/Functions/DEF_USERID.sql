CREATE function [dbo].[DEF_USERID]()
returns int as 
begin
  declare @res int
  select @res = ID from DEF_USERS where upper(LOGINNAME)=upper(ORIGINAL_LOGIN()) and isnull(ISGROUP,0) = 0
  if @res is null
    select @res = ID from DEF_USERS where upper(LOGINNAME2)=upper(ORIGINAL_LOGIN()) and isnull(ISGROUP,0) = 0
  return @res
end
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[DEF_USERID] TO [IPG-DOMAIN\IPGL_Integr_MSCRM]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[DEF_USERID] TO [EMEA\DEPCS]
    AS [dbo];

