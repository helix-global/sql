CREATE PROCEDURE [dbo].[MSG_SEND_WITH_OPTIONS] 
  @aUserID int, @aTo nvarchar(1024), @aToCC nvarchar(1024), @aSubj nvarchar(1024), @aBoby varchar(max), @aOptions nvarchar(250)
AS
BEGIN

  INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR, MSGOPTIONS) 
  values (1, NEWID(), @aTo, @aToCC , @aSubj,  @aBoby, GETDATE(), @aUserID, @aOptions)

END