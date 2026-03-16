create function [dbo].[PR_DEVICE_BOMITEM_BYNAME](@DeviceID int, @BomName nvarchar(100))
returns int as 
begin

  declare @res int
  
  select top 1 @res = B.PARTID
  from PR_OPERATION A with (nolock) 
  left join PR_OPERATION_INSTALL B with (nolock) on B.OPERID = A.ID
  left join PR_MODELTYPE_BOM C with (nolock) on C.ID = B.BOMID
  where A.DEVICEID = @DeviceID
    and A.S_S in (1000013,1000019,1000038,1000116)
    and C.NAME = @BomName
    and not exists (select U.ID from PR_OPERATION_UNINSTALL U where U.INSTALLROWID = B.ID)
  order by A.ID desc
  
  return @res  

end