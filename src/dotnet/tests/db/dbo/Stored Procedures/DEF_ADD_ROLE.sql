create PROCEDURE [dbo].[DEF_ADD_ROLE] @aUserID int, @aGroup nvarchar(50), @aUntil datetime
AS
BEGIN

  declare @GroupID int
  select @GroupID = A.ID from DEF_USERS A with(nolock) where A.LOGINNAME = @aGroup and A.ISGROUP = 1
  
  if @GroupID is null
  begin
     raiserror('Group not found.',16,0)
     return
  end  
  
  declare @UserID int
  select @UserID = A.ID from DEF_USERS A with(nolock) where A.ID = @aUserID and isnull(A.ISGROUP,0) = 0

  if @UserID is null
  begin
     raiserror('User not found.',16,0)
     return
  end  
  
  declare @usr int = dbo.DEF_USERID()

  insert into DEF_USERSTOGROUP (USERID,GROUPID,DCLS,GID,S_CDT,S_CR)
  values (@UserID,@GroupID,@aUntil,newid(),getdate(),@usr)

END