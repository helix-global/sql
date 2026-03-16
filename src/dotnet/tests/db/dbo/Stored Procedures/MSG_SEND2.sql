CREATE PROCEDURE [dbo].[MSG_SEND2]
  @aUserID int,
  @aTo nvarchar(max),
  @aToCC nvarchar(max),
  @aSubj nvarchar(1024),
  @aBoby nvarchar(max)
as
begin

  insert into [dbo].[MSG_OUTGOING]
         ([S_S],  [GID],    [MSGTO],  [MSGCC],  [MSGSUBJ],  [MSGBODY],  [S_CDT],    [S_CR])
  values (1,      newid(),  @aTo,     @aToCC,   @aSubj,     @aBoby,     getdate(),  @aUserID)

end