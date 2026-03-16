
CREATE FUNCTION [dbo].[IMS_TRAINING_PLAN_DATE]
(
    @trainingEmplId int
)
RETURNS datetime
AS
BEGIN
    
    declare @ret datetime 

    select @ret = D.DD
        from IMS_DEP_SCHEDULE S 
            join IMS_DEP_SCHEDULE_T T on S.ID=T.VNESHID
            join IMS_TRAINING_SCHEDULE_DATES D on T.SCHEDULEDATEID=D.ID
            join IMS_TRAINING_SCHEDULE E on S.SCHEDULEID=E.ID
            join IMS_TRAINING_SCHEDULE_EMPL L on E.ID=L.VNESHID and T.EMPLID=L.EMPLID
        where S.S_S in(2130030,2130031 /*Approved or Planned*/)
            and L.ID=@trainingEmplId

    return @ret

END