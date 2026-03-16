

CREATE function [dbo].[COM_EMPL_BY_USER](@UserID int)
returns int as
begin
  declare @res int
  select @res = max(A.EMPLOYEEID) from DEF_USERS A with (nolock) where A.ID = @UserID
  return @res
end