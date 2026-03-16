CREATE function [dbo].[COM_USER_BY_EMPL](@EmployeeID int)
returns int as 
begin
  declare @res int
  select @res = max(A.ID) from DEF_USERS A with (nolock) where A.EMPLOYEEID = @EmployeeID
  return @res
end