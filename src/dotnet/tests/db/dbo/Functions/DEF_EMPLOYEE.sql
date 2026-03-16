create function [dbo].[DEF_EMPLOYEE](@UserID int)
returns int as 
begin
  declare @res int
  select @res = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @UserID
  return @res
end