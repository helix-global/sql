CREATE function [dbo].[COM_EMPLOYEE_DEP](@EmployeeID int, @Date datetime)
returns int
begin
  
  declare @res int = (select top(1) DEPID from dbo.COM_EMPLOYEE_DEPS(@EmployeeID) where DBEG<=@Date and (DEND is null or DEND>=@Date))

  return isnull(@res, -1)

end