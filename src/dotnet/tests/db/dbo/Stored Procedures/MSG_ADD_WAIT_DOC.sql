CREATE PROCEDURE [dbo].[MSG_ADD_WAIT_DOC] 
  @DocWaitOID int,@DocOID int,@DocID int,@DepID int,@aSubj varchar(250),@aLastMDT datetime,@aLastMR int
AS
BEGIN

  declare @now datetime
  set @now = getdate()
  
  delete from MSG_WAIT_DOCS where DOCOID = @DocOID and DOCID = @DocID

  delete from MSG_WAIT_DOCS where EXPIREDDATE < @now

  INSERT INTO MSG_WAIT_DOCS (S_S,SENDINGOID,DOCOID, DOCID, SUBJ, LAST_MDT, LAST_MR, DEPID, S_CR, S_CDT, EXPIREDDATE) 
  values (1,@DocWaitOID,@DocOID,@DocID,@aSubj,@aLastMDT,@aLastMR, @DepID, @aLastMR, getdate(), dateadd(day,14,@now))

END