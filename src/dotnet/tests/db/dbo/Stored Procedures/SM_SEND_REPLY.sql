CREATE PROCEDURE [dbo].[SM_SEND_REPLY] @aID int, @UserID int, @aMode int
AS
BEGIN
set nocount on

    declare @BoxID int
    declare @DepID int
    declare @errMsg nvarchar(max)
    
    /* ящик который привязан к подразделению сотрудника */
    
    select @BoxID = C.ID
          ,@DepID = B.DEPID
    from DEF_USERS A with (nolock)
    left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
    left join SM_EMAIL_BOXES C with (nolock) on C.DEPID = B.DEPID
    where A.ID = @UserID
    
    if @BoxID is null
    begin
       raiserror('#EUnable to define outgoing email box to send the message.',16,0)
       set nocount off
       return
    end
 
    declare @msgTo nvarchar(max)
    declare @msgCC nvarchar(max)
    declare @msgSubj nvarchar(1024) 
    declare @caseN nvarchar(20)

    declare @msgID int
    declare @replID int
    declare @callType int
    declare @callDirection int
    declare @caseID int
    
    select @replID = A.REPLY2ID
          ,@caseN = C.ND
          ,@msgSubj = A.SUBJ
          ,@callType = isnull(A.SCTYPE,0)
          ,@callDirection = isnull(A.SCDIRECTION,0)
          ,@caseID = A.CASEID
    from SM_SERVICECALL A with (nolock)
    left join SM_SERVICECASE C with (nolock) on C.ID = A.CASEID
    where A.ID = @aID
    
    if @callType <> 2 /*email*/ or @callDirection <> 2 /*outgoing*/
    begin
       set @errMsg = '#EOnly "outgoing" service call with "email" type can be processed by "Send" method.'
       raiserror(@errMsg,16,0)
       set nocount off
       return
    end
    
    if @msgSubj not like '%##%##%' and len(@caseN) > 1
       set @msgSubj = '##'+isnull(@caseN,'NA') + '## '+isnull(@msgSubj,'')
    

    declare @errContact nvarchar(200)
    select top 1 @errContact = B.NAME
      from SM_SERVICE_CALL_T A with (nolock)
 left join COM_CUST_CONTACTS B with (nolock) on B.ID = A.CNTID
     where A.VNESHID = @aID
       and B.EMAIL is null

    if @errContact is not null
    begin
       set @errMsg = '#EUnable to define outgoing email address for contact "'+ltrim(rtrim(@errContact))+'". Please specify email address.'
       raiserror(@errMsg,16,0)
       set nocount off
       return
    end

    select @msgTo = isnull(@msgTo,'')+B.EMAIL+'; '
    from SM_SERVICE_CALL_T A with (nolock)
    left join COM_CUST_CONTACTS B with (nolock) on B.ID = A.CNTID
    where A.VNESHID = @aID
      and B.EMAIL is not null

    /*select @msgCC = isnull(@msgCC,'')+A.EMAIL+'; '*/ /*KB514*/
    select @msgTo = isnull(@msgTo,'')+A.EMAIL+'; '
    from SM_SERVICE_CALL_TINT A with (nolock)
    where A.VNESHID = @aID
      and A.EMAIL is not null
      
    /*KB514*/
    select @msgCC = isnull(@msgCC,'')+B.EMAIL+'; '
    from SM_SERVICE_CALL_T_CC A with (nolock)
    left join COM_CUST_CONTACTS B with (nolock) on B.ID = A.CNTID
    where A.VNESHID = @aID
      and B.EMAIL is not null

    select @msgCC = isnull(@msgCC,'')+A.EMAIL+'; '
    from SM_SERVICE_CALL_TINT_CC A with (nolock)
    where A.VNESHID = @aID
      and A.EMAIL is not null
    /* /KB514 */
      
      /*
    if not (isnull(@msgTo,'') like '%@%')
    begin
       set @msgTo = @msgCC
       set @msgCC = null
    end 
    */     

    if not (isnull(@msgTo,'') like '%@%')
    begin
       raiserror('#EUnable to define outgoing email address to send the message.',16,0)
       set nocount off
       return
    end

    insert into SM_OUTGOING (S_S,  S_CDT, S_CR, BOXID, GID, SERVICECALLID, MSGTO, MSGCC, MSGSUBJ, MSGBODY) 
    select -1, getdate(), @UserID, @BoxID, newid(), A.ID, @msgTo, @msgCC, @msgSubj, A.SCBODY
    from SM_SERVICECALL A
    where A.ID = @aID
  
    set @msgID = @@identity
    
    insert into SM_OUT_ATTACHEMENTS (GID, S_CR, S_CDT, VNESHID, FILENAME, FILEDATE, FILESIZE, FILEBLOB)
    select newid(), @UserID, getdate(), @msgID, A.FILENAME, A.FILEDATE, A.FILESIZE, A.FILEBLOB
    from SM_SERVICECALL_FILES A
    where A.VNESHID = @aID

    update SM_OUTGOING set S_S = 1 where ID = @msgID
    
    update SM_SERVICECALL set SM_SERVICECALL.SENT_DT = getdate(), SENT_UID = @UserID, UNREAD = null where ID = @aID
    
    update SM_SERVICECALL set SM_SERVICECALL.REPLY_DT = getdate(), REPLY_UID = @UserID, UNREAD = 5/*replied*/ where ID = @replID and SM_SERVICECALL.REPLY_DT is null

    update SM_SERVICECASE set WAITRESPONSE_FLAG = dbo.SM_SERVICECASE_WAITING4RESPONSE(ID) where ID = @CaseID   


    
set nocount off
END