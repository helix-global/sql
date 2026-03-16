CREATE function [dbo].[DEF_USER_GROUPS](@UserID int)
returns nvarchar(max) as 
begin
  declare @res nvarchar(max)
  set @res = ''
  select @res = @res + A.LOGINNAME + '; ' from DEF_USERS A with (nolock) 
    where A.ID in (select B.GROUPID from DEF_USERSTOGROUP B with (nolock) where B.USERID = @UserID)
  return @res
end