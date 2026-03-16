CREATE FUNCTION [dbo].[COM_TRAINERS_OPERATIONS]
(
    @UserID int
)
RETURNS @ret TABLE (ID int)
AS
BEGIN

	declare @employeeId int
	set @employeeId = dbo.DEF_EMPLOYEE(@UserID)
	    
    declare @skills table (ID int)

    insert into @skills (ID)
        select S.SKILLID from
            COM_EMPLOYEE_SKILL S with (nolock)
        where S.EMPLOYEEID=@employeeId and S.CAN_TRAIN=1
                and dbo.COM_EMPLOYEE_HAS_SKILL2(@employeeId,S.SKILLID,0)=1

    insert into @ret (ID)
    select T.OPERID 
        from COM_TRAINING_OPERATIONS T 
            join COM_EMPLOYEE E with (nolock) on T.TRAINER_ID=E.ID 
            join COM_TRAINING TR on T.TRAININGID=TR.ID
        where TR.SKILLID in (select ID from @skills) and T.CHECKED_TRAINER_ID is null
    union 
    select T.OPERID 
        from COM_TRAINING_PREPARATORY T 
            join COM_EMPLOYEE E with (nolock) on T.TRAINER_ID=E.ID 
            join COM_TRAINING TR on T.TRAINING_ID=TR.ID
        where TR.SKILLID in (select ID from @skills) and T.CHECKED_TRAINER_ID is null
    union 
    select T.OPERID 
        from COM_TRAINING_MAINTENANCE T 
            join COM_EMPLOYEE E with (nolock) on T.TRAINER_ID=E.ID 
            join COM_TRAINING TR on T.TRAININGID=TR.ID
        where TR.SKILLID in (select ID from @skills) and T.CHECKED_TRAINER_ID is null
    
    RETURN 
END