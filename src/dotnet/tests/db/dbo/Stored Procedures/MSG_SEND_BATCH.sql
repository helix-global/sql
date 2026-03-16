CREATE PROCEDURE [dbo].[MSG_SEND_BATCH] @aUserID int,
  @data dbo.MSG_MESSAGES_BATCH readonly
AS
BEGIN

  INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR) 
  select 1, NEWID(), MSG_TO, MSG_TOCC , MSG_SUBJ,  MSG_BODY, GETDATE(), @aUserID
  from @data 
  where MSG_TO is not null
    and MSG_SUBJ is not null

END