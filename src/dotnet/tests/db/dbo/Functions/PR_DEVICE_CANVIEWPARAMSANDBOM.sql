CREATE function [dbo].[PR_DEVICE_CANVIEWPARAMSANDBOM](@aDeviceID int, @aUserID int, @aMode int)
returns int
as
begin
  /*KB1362 в режиме "надо срочно" */              
  
 declare @modelDepGID uniqueidentifier
     
 select @modelDepGID = C.GID
 from PR_DEVICE A with (nolock)
 left join PR_MODELS B with (nolock) on B.ID = A.MODELID
 left join COM_DEPARTMENTS C with (nolock) on C.ID = B.DEPID
 where A.ID = @aDeviceID
  
 if @modelDepGID = 'd4f90a74-63ee-4641-a1b6-57338aefc0dd' /*YLA*/
 begin
 
   if dbo.COM_USER_IN_DEPARTMENT(@aUserID,'dd1f3353-0df3-4b9c-afc3-8c0f7a8cf559'/*Japan*/,1) =1  
     return 0

   if dbo.COM_USER_IN_DEPARTMENT(@aUserID,'ae96b868-9894-41bd-bb35-835230871198'/*IPG Beijing*/,1) =1  /*KB2131*/
     return 0

     
 end 
  
 return 1;
end;