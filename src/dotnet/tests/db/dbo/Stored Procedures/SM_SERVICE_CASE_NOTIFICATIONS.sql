CREATE procedure [dbo].[SM_SERVICE_CASE_NOTIFICATIONS] 
AS
    set xact_abort on

    declare @EMAIL nvarchar(1024), @ND nvarchar(12), @ID int, @USERID int, @subj nvarchar(1000), @body nvarchar(2000)
    declare @t table (EMAIL nvarchar(1024), ND nvarchar(12), ID int, USERID int)
    
    insert into @t (EMAIL, ND, ID, USERID)
    select ISNULL(E.EMAIL,'') + ';' + ISNULL(D.EMAIL,'') as DEP_EMAIL
            , C.ND
            , C.ID
            , C.REMINDER_USERID
        from SM_SERVICECASE C 
            join COM_EMPLOYEE E on C.RESP_EMPLID=E.ID
            join SM_EMAIL_BOXES D on C.SDEPID=D.DEPID
        where C.REMINDER_DATETIME is not null 
                and C.REMINDER_DATETIME<getdate()
                and isnull(C.REMINDER_SENT,0)=0 
                and (E.EMAIL is not null or D.EMAIL is not null)
        

    begin tran

    DECLARE cur_SM_SERVICE_CASE_NOTIFICATIONS CURSOR FOR
    SELECT EMAIL, ND, ID, USERID
        from @t
                    
    OPEN cur_SM_SERVICE_CASE_NOTIFICATIONS

    FETCH NEXT FROM cur_SM_SERVICE_CASE_NOTIFICATIONS INTO @EMAIL, @ND, @ID, @USERID

    WHILE @@FETCH_STATUS=0
    BEGIN
        
        set @subj = 'Service Case ##' + @ND + '## should be processed'
        set @body = 'Dear all,<br/><br/>Service Case <a href = "a2l:\\Link=doc.sm_service_case.' + CAST(@ID as nvarchar(20)) + '">'+ @ND +'</a> should be processed'

        exec dbo.MSG_SEND @USERID
						, @EMAIL
						, null
						, @subj
						, @body

        update SM_SERVICECASE set REMINDER_SENT=1
            where ID=@ID

        FETCH NEXT FROM cur_SM_SERVICE_CASE_NOTIFICATIONS INTO @EMAIL, @ND, @ID, @USERID
    END

    CLOSE cur_SM_SERVICE_CASE_NOTIFICATIONS
    DEALLOCATE cur_SM_SERVICE_CASE_NOTIFICATIONS
    
    commit