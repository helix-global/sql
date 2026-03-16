CREATE function [dbo].[COM_EMPLOYEE_IN_DEP](@EmployeeID int, @DepID int, @Date datetime)
returns int
begin
  
  if exists (select * from dbo.COM_EMPLOYEE_DEPS(@EmployeeID) where DEPID=@DepID and DBEG<=@Date and (DEND is null or cast(DEND as date) >= cast(@Date as date)))
  begin
    return 1  
  end

  return 0

end