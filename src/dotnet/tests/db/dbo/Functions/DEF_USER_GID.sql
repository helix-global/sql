create function [dbo].[DEF_USER_GID](@UserID int, @mode int)
returns uniqueidentifier as 
begin
  declare @res uniqueidentifier
  select @res = A.GID from DEF_USERS A with(nolock) where A.ID = @UserID
  return @res
end