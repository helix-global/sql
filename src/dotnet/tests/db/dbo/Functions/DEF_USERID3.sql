create function [dbo].[DEF_USERID3](@loginName nvarchar(250))
returns int as 
begin
  declare @res int
  select @res = ID from DEF_USERS where upper(LOGINNAME)=upper(@loginName) and isnull(ISGROUP,0) = 0
  if @res is null
    select @res = ID from DEF_USERS where upper(LOGINNAME2)=upper(@loginName) and isnull(ISGROUP,0) = 0
  return @res
end