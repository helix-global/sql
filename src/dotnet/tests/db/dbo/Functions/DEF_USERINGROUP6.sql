create function [dbo].[DEF_USERINGROUP6](@aGroupName nvarchar(50))
returns int as 
begin
  
  declare @aUserID int
  
  set @aUserID = dbo.DEF_USERID()
  
  declare @aGroupID int
  select top 1 @aGroupID = A.ID from DEF_USERS A with (nolock) where A.LOGINNAME = @aGroupName and A.ISGROUP = 1
  if @aGroupID is null
     return 0;
     
  return dbo.DEF_USERINGROUP(@aUserID,@aGroupID,getdate())
     
end