CREATE function [dbo].[DEF_DEF_USER_2_FINEACCESS](@aID int, @aUserID int)
returns nvarchar(100) as 
begin

if exists (select D.ID 
             from DEF_USERSTOGROUP D with (nolock) 
             left join DEF_USERS F with (nolock) on F.ID = D.GROUPID 
            where D.USERID = @aID 
              and dbo.DEF_F_ACCESS2(F.ARC,null,1000260,getdate(),@aUserID,0) <> 1
              /*and isnull(F.LADM,0) <> 1*/
            )  
  return 'FullReadOnly;NoAllMarkedActions;'
     
return null 

end;