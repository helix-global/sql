create PROCEDURE [dbo].[MSG_SEND_TOEMPLOYEE2] 
  @aUserID int, @aToEmplID int, @aCC nvarchar(1024), @aSubj nvarchar(1024), @aBoby nvarchar(max)
AS
BEGIN
  
  declare @vTo nvarchar(1024)

  select @vTo = C.EMAIL
  from COM_EMPLOYEE C with (nolock)
  where C.ID = @aToEmplID
    and C.EMAIL is not null
  
  if LEN(@vTo) > 1
  begin 
    insert into MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR) 
    values (1, NEWID(), @vTo , @aCC , @aSubj,  @aBoby, GETDATE(), @aUserID)
  end

END