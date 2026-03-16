CREATE function [dbo].[PR_DEVICE_INUSE](@aMode int,@aDeviceID int)
returns int
as
begin
  if exists (select A.ID 
               from PR_OPERATION_INSTALL A with (nolock) 
              where A.PARTID = @aDeviceID
                and dbo.PR_UNINSTALL_ID(A.ID) is null)
      return 1;                
                
  
  return 0;
end;