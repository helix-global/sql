
CREATE FUNCTION [dbo].[COM_EMPLOYEE_DEP_BY_DATE](@EmployeeID int, @date datetime)
RETURNS INT
AS
BEGIN

	declare @ret int

  if not exists (select ID from COM_EMPL_PERIODS where EMPLID=@EmployeeID)
  begin

    
    select @ret=DEPID
		from COM_EMPLOYEE 
		where ID=@EmployeeID

  end
  else
  begin

	select @ret = DEPID
		from COM_EMPL_PERIODS E
		where E.EMPLID=@EmployeeID and @date>=E.DBEG and (E.DEND is null or @date<DATEADD(day,1,E.DEND))

  end
     
  return @ret
END