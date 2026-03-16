CREATE PROCEDURE [dbo].[MSG_REPLYWITHFILES_ALL_ADDCC] 
  @InMessageID int, @AddCC nvarchar(1024), @aAnswer varchar(max)
AS
BEGIN
  set nocount on

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
  
  
  declare @ansID int
  
  INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR, MSGCC, INCOMINGID) 
  values (0,NEWID(),@inFrom,'Re: '+@inSubj,@aAnswer, GETDATE(), 0, @inCC, @InMessageID)
  
  set @ansID = @@IDENTITY
  
  insert into MSG_OUT_ATTACHEMENTS (VNESHID,FILENAME,FILESIZE,FILEDATE,FILEBLOB)
  select @ansID,A.FILENAME,A.FILESIZE,A.FILEDATE,A.FILEBLOB
  from MSG_IN_ATTACHEMENTS A
  where A.VNESHID = @InMessageID
  
  update MSG_OUTGOING set S_S = 1 where ID = @ansID
  
  set nocount off 
END