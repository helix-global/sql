CREATE PROCEDURE [dbo].[MSG_REPLY_ALL] 
  @InMessageID int, @aAnswer varchar(max)
AS
BEGIN

  INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR, MSGCC, INCOMINGID) 
  select 1, NEWID(), A.MSGFROM, 'Re: '+isnull(A.MSGSUBJ,''), @aAnswer, GETDATE(), 0, A.MSGCC, A.ID
  from MSG_INBOX A with (nolock)
  where A.ID = @InMessageID

END