create function [dbo].[DEF_USERINGROUP1](@aUserID int,@aGroupName1 nvarchar(50))
returns int as 
begin
  
  if exists (select A.ID 
               from DEF_USERS A with (nolock) 
              where A.LOGINNAME = @aGroupName1
                and A.ISGROUP = 1
                and dbo.DEF_USERINGROUP(@aUserID,A.ID,getdate()) = 1
                )
     return 1
  
  return 0                
     
end