create PROCEDURE [dbo].[MSG_SEND_TOGROUP2] 
  @aUserID int, @aGroupID int, @aDepID int, @aSubj nvarchar(1024), @aBoby varchar(max)
AS
BEGIN
  
  declare @vTo nvarchar(1024)

  select @vTo = isnull(@vTo,'') + C.EMAIL + '; '
  from dbo.DEF_USERSINGROUP(@aGroupID) A
  left join DEF_USERS B with (nolock) on B.ID = A.ID
  left join COM_EMPLOYEE C on C.ID = B.EMPLOYEEID
  where C.EMAIL is not null
    and C.DEPID = @aDepID
  
  if LEN(@vTo) > 1
  begin 
    insert into MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR) 
    values (1, NEWID(), @vTo , @aSubj,  @aBoby, GETDATE(), @aUserID)
  end

END