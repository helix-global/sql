CREATE function [dbo].[PR_DEVICE_BOMITEM](@DeviceID int, @BomID int)
returns int as 
begin

  declare @res int
  
  select top 1 @res = B.PARTID
  from PR_OPERATION A with (nolock) 
  left join PR_OPERATION_INSTALL B with (nolock) on B.OPERID = A.ID
  where A.DEVICEID = @DeviceID
    and A.S_S in (1000013,1000019,1000038,1000116)
    and B.BOMID = @BomID
    and not exists (select U.ID from PR_OPERATION_UNINSTALL U where U.INSTALLROWID = B.ID)
  order by A.ID desc
  
  return @res  

end