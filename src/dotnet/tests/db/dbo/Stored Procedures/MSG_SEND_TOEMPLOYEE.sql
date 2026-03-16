CREATE PROCEDURE [dbo].[MSG_SEND_TOEMPLOYEE] 
  @aUserID int, @aToEmplID int, @aSubj nvarchar(1024), @aBoby nvarchar(max)
AS
BEGIN
  
  declare @vTo nvarchar(1024)

  select @vTo = C.EMAIL
  from COM_EMPLOYEE C with (nolock)
  where C.ID = @aToEmplID
    and C.EMAIL is not null
  
  if LEN(@vTo) > 1
  begin 
    insert into MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR) 
    values (1, NEWID(), @vTo , @aSubj,  @aBoby, GETDATE(), @aUserID)
  end

END