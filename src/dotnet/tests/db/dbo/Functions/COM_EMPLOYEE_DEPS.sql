CREATE FUNCTION [dbo].[COM_EMPLOYEE_DEPS](@EmployeeID int)
RETURNS 
@res TABLE 
(
	 EMPLID int   
	,DEPID int 
	,DBEG datetime
	,DEND datetime
)
AS
BEGIN

  if not exists (select ID from COM_EMPL_PERIODS where EMPLID=@EmployeeID)
  begin

    insert into @res (EMPLID, DEPID, DBEG, DEND)
    select 
      @EmployeeID
      ,DEPID
      ,isnull(EMPDATE,S_CDT)
      ,getdate()
    from COM_EMPLOYEE 
    where ID=@EmployeeID

    return
  end

  insert into @res (EMPLID, DEPID, DBEG, DEND)
  select EMPLID, DEPID, DBEG, DEND
  from COM_EMPL_PERIODS
  where EMPLID=@EmployeeID

  return
END