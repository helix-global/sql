CREATE function [dbo].[DEF_USERINGROUP5](@aUserID int,@aGroupName1 nvarchar(50),@aOrGroupName2 nvarchar(50),@aOrGroupName3 nvarchar(50),@aOrGroupName4 nvarchar(50),@aOrGroupName5 nvarchar(50))
returns int as 
begin
  
  if exists (select A.ID 
               from DEF_USERS A with (nolock) 
              where A.LOGINNAME in (@aGroupName1,@aOrGroupName2,@aOrGroupName3,@aOrGroupName4,@aOrGroupName5) 
                and A.ISGROUP in (1,2)
                and dbo.DEF_USERINGROUP3(@aUserID,A.ID) = 1
                )
     return 1
  
  return 0                
     
end