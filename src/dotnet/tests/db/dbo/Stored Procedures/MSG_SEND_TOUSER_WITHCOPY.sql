CREATE PROCEDURE MSG_SEND_TOUSER_WITHCOPY 
  @aUserID int, @aToUserID int, @aToCC nvarchar(1024), @aSubj nvarchar(1024), @aBoby varchar(max)
AS
BEGIN
  
  declare @vTo nvarchar(1024)

  select @vTo = C.EMAIL
  from DEF_USERS B with (nolock) 
  left join COM_EMPLOYEE C on C.ID = B.EMPLOYEEID
  where B.ID = @aToUserID
    and C.EMAIL is not null
    
  if @vTo is null and @aToCC is not null
  begin
     set @vTo = @aToCC
     set @aToCC = null
  end
  
  if LEN(@vTo) > 1
  begin 
    insert into MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR) 
    values (1, NEWID(), @vTo , @aToCC, @aSubj, @aBoby, GETDATE(), @aUserID)
  end

END