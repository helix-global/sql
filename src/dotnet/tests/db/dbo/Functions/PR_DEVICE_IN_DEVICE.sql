CREATE function [dbo].[PR_DEVICE_IN_DEVICE](@aDeviceID int,@aSkipID int)
returns int
as
begin
  declare @res int
  
  select top 1 @res = B.DEVICEID
  from PR_OPERATION_INSTALL A with (nolock) 
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where A.PARTID = @aDeviceID
    and A.ID <> isnull(@aSkipID,0)
    and dbo.PR_UNINSTALL_ID(A.ID) is null
    and (B.S_S IN (1000013, 1000019, 1000038, 1000116))
   
  return @res;
end;