-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date, ,>
-- Description: <Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[COM_EMPLOYEE_HAS_SKILL2]
(
    @employeeId int
	, @skillId int
	, @withExpiring int --добавить скиллы, истекающие в ближайшие 2 недели
)
RETURNS int
AS
BEGIN
    
    if not exists(select S.ID 
                    from COM_EMPLOYEE_SKILL S with (nolock)
                    where S.EMPLOYEEID=@employeeId and S.SKILLID=@skillId)
        return 0

    declare @expDate datetime

    select @expDate=D.EXPIRATION_DATE
        from COM_EMPLOYEE_SKILL_EXPIRATION_DATES D
        where D.EMPLOYEEID=@employeeId and D.SKILLID=@skillId
	
	if @withExpiring=1
		if @expDate<=dateadd(week,2,getdate())
			return 0

	if isnull(@withExpiring,0)=0
		if @expDate<=getdate()
			return 0

    return 1

END