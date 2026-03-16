
CREATE PROCEDURE [dbo].[IMS_SEND_MESSAGES_AFTER_APPROVE]
    ( @shedId int, @userID int )
AS
BEGIN
    
    declare @depName nvarchar(100), @trName nvarchar(250), @planId int

    select @depName=D.NAME, @trName=P.NAME, @planId=P.ID
        from IMS_DEP_SCHEDULE S with(nolock)
            left join COM_DEPARTMENTS D with(nolock) on S.DEPID=D.ID
            left join IMS_TRAINING_SCHEDULE T with(nolock) on S.SCHEDULEID=T.ID
            left join IMS_TRAINING_PLAN P with(nolock) on T.PLANID=P.ID
       where S.ID = @shedId

    declare @mess nvarchar(1000), @subj nvarchar(200), @msgTo nvarchar(1024) = ''

    set @subj = 'General Qualification by Department has been approved'
    set @mess = 'Dear all, ' + CHAR(10) + CHAR(13)+
                'General Qualification by Department has been approved in department "' + @depName + '"'+ CHAR(10) + CHAR(13)+
                'General Qualification: "' + @trName + '"'


    select @msgTo = @msgTo + ISNULL(E.EMAIL + ';','')
        from IMS_TRAINING_PLAN_NOTI N with(nolock)
            join COM_EMPLOYEE E with(nolock) on N.EMPLID=E.ID
        where N.VNESHID=@planId


    exec MSG_SEND @userID, @msgTo, '', @subj, @mess 

END