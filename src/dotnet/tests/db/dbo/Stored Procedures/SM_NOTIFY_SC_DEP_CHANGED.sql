CREATE PROCEDURE [dbo].[SM_NOTIFY_SC_DEP_CHANGED]
( @scID int, @newDepID int, @userID int )
AS
BEGIN

    declare @scNum nvarchar(12)

    select @scNum=S.ND
    from SM_SERVICECASE S
    where S.ID=@scID

    declare @employeeName nvarchar(200), @employeeDepName nvarchar(100)

    select @employeeName=E.NAME, @employeeDepName=D.NAME
        from COM_EMPLOYEE E 
            join DEF_USERS U on E.ID=U.EMPLOYEEID
            join COM_DEPARTMENTS D on E.DEPID=D.ID
    where U.ID=@userID
    
    declare @msg nvarchar(1000)
    set @msg = 'Dear All,<br>' +
                    'The service case <a href="a2l:\\Link=doc.sm_service_case.' + cast(@scID as nvarchar(20)) + '">' + @scNum + '</a> was transferred to you by ' + @employeeName + ', ' + @employeeDepName + '.<br>' +
                    'Please, do not answer this e-mail.<br><br>' +
                    'Production Database'
                    
    declare @subj nvarchar(1024)  /*KB1492*/
    set @subj = 'Department of Service Case "'+@scNum+'" has been changed'

    INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR) 
        select 1, NEWID(), E.EMAIL, @subj, @msg, GETDATE(), @UserID
        from SM_EMAIL_BOX_CHANGED_SUBSCRIBERS S
            join COM_EMPLOYEE E on S.EMPLOYEE_ID=E.ID
            join SM_EMAIL_BOXES B on S.SM_EMAIL_BOX_ID=B.ID
        where B.DEPID=@newDepID and E.EMAIL is not null and B.DISABLED=0
        union 
        select 1, NEWID(), B.EMAIL, @subj, @msg, GETDATE(), @UserID
        from SM_EMAIL_BOXES B 
        where not exists(select * 
                            from SM_EMAIL_BOX_CHANGED_SUBSCRIBERS S 
                                inner join SM_EMAIL_BOXES B on S.SM_EMAIL_BOX_ID=B.ID
                            where B.DEPID=@newDepID and B.DISABLED=0) and B.DEPID=@newDepID


     /*KB1492*/
     declare @lastCall int
     select top 1 @lastCall = A.ID 
     from SM_SERVICECALL A with (nolock) 
     where A.CASEID = @scID 
       and A.SCDIRECTION = 1 /*incoming*/
     order by A.ID desc
     if @lastCall is not null
     begin
       update SM_SERVICECALL set UNREAD = 1 /*Unread*/ where ID = @lastCall 
     end


END