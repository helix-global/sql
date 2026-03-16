CREATE PROCEDURE [dbo].[MSG_REPLY_ALL_ADDCC] 
  @InMessageID int, @AddCC nvarchar(1024), @aAnswer varchar(max)
AS
BEGIN

  declare @inFrom nvarchar(1024)
  declare @inSubj nvarchar(1024)
  declare @inCC nvarchar(1024)
  declare @addRealCC nvarchar(200)
  
  select @inFrom = A.MSGFROM
       , @inSubj = isnull(A.MSGSUBJ,'')
       , @inCC = isnull(A.MSGCC,'')
       , @addRealCC = isnull(A.PACKETCREATEDEMAIL,'')
  from MSG_INBOX A with (nolock)
  where A.ID = @InMessageID

  if len(@AddCC) > 1
  begin
     if LEN(@inCC) > 1
       set @inCC = @inCC + ';' 
     set @inCC = @inCC + @AddCC 
  end
  
  if len(@addRealCC) > 1
  begin
     if LEN(@inCC) > 1
       set @inCC = @inCC + ';' 
     set @inCC = @inCC + @addRealCC
  end
  
  INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR, MSGCC, INCOMINGID) 
  values (1,NEWID(),@inFrom,'Re: '+@inSubj,@aAnswer, GETDATE(), 0, @inCC, @InMessageID)

END