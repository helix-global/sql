create function [dbo].[DEF_USERINGROUP4](@aUserID int,@aGroupName nvarchar(50),@aDate datetime)
returns int as 
begin
  
  declare @aGroupID int
  select top 1 @aGroupID = A.ID from DEF_USERS A with (nolock) where A.LOGINNAME = @aGroupName and A.ISGROUP = 1
  if @aGroupID is null
     return 0;
     
  return dbo.DEF_USERINGROUP(@aUserID,@aGroupID,@aDate)
     
end