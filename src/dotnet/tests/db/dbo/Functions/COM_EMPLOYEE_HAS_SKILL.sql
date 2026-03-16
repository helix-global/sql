-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[COM_EMPLOYEE_HAS_SKILL]
(
    @employeeId int, @skillId int
)
RETURNS int
AS
BEGIN
    
    if not exists(select S.ID 
                    from COM_EMPLOYEE_SKILL S 
                    where S.EMPLOYEEID=@employeeId and S.SKILLID=@skillId)
        return 0

    declare @expDate datetime

    select @expDate=D.EXPIRATION_DATE
        from COM_EMPLOYEE_SKILL_EXPIRATION_DATES D
        where D.EMPLOYEEID=@employeeId and D.SKILLID=@skillId

    if @expDate<getdate()
        return 0


    return 1

END