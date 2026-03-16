CREATE PROCEDURE [dbo].[COM_ADD_SKILL_TO_EMPLOYEE]
(@trainingID int, @UserID int)
AS
BEGIN
	
	declare @userOperID int, @skillID int, @employeeSkillID int, @employeeID int

    select @userOperID = U.ID, @skillID=T.SKILLID, @employeeID=T.EMPLOYEEID
    from COM_TRAINING T 
            join DEF_USERS U on T.EMPLOYEEID=U.EMPLOYEEID
        where T.ID=@trainingID 

    select @employeeSkillID=S.ID
    from COM_EMPLOYEE_SKILL S where S.EMPLOYEEID=@employeeID and S.SKILLID=@skillID

    if @employeeSkillID is null
        insert into COM_EMPLOYEE_SKILL (EMPLOYEEID, CAN_TRAIN/*, NEXT_TRAINING_DATE*/, S_S, SKILLID, S_CR, S_CDT, GID, SKILL_DATE)
            VALUES ( @employeeID, 0/*, [dbo].[COM_NEXT_TRAINING_DATE](@skillID, @userOperID)*/, 1, @skillID, @UserID, getdate(), NEWID(), getdate())
  /*  else
        update COM_EMPLOYEE_SKILL set NEXT_TRAINING_DATE=[dbo].[COM_NEXT_TRAINING_DATE](@skillID, @userOperID)
            where ID=@employeeSkillID 
*/
END