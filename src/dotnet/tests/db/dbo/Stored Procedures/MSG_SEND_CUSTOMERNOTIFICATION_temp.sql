CREATE PROCEDURE [dbo].[MSG_SEND_CUSTOMERNOTIFICATION_temp] @aID int
AS
BEGIN

    set nocount on
    
    declare @userID int = dbo.DEF_USERID()
    declare @messID int
	
    INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR, CUSTOMERSUBSCRID ) 
    select 0,newid(),B.ADR,B.CC,B.SUBJ,B.MSG,getdate(),@userID,@aID
    from MSG_FILENOTIFICATIONS_OUT A with (nolock)
    left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
    where A.ID = @aID
      
    set @messID = @@identity
      
    insert into MSG_OUT_ATTACHEMENTS (GID,VNESHID,FILENAME,FILEDATE,FILESIZE,FILEBLOB)
    select newid(),@messID,A.FILENAME,A.FILEDATE,A.FILESIZE,A.FILEBLOB
    from MSG_FILENOTIFICATIONS_OUT_FILES A with (nolock)
    where A.VNESHID = @aID

    update MSG_OUTGOING set S_S = 1 where MSG_OUTGOING.ID = @messID
	
	update MSG_FILENOTIFICATIONS_OUT set S_S = 1000180 /*sent*/, SENTDATE = getdate(), MSGID = @messID  where MSG_FILENOTIFICATIONS_OUT.ID = @aID
	
	set nocount off	
	
END