create function [dbo].[PR_DEVICE_BOMITEM_QTY](@DeviceID int, @BomItemID int,@aMode int)
returns decimal(20,10) as 
begin
  declare @resQ decimal(20,10)
  select top 1 @resQ = A.PARTQUANTITY from PR_DEVICE_BOM A where A.DEVICEID = @DeviceID and A.UNINSTALLOPERID is null and A.BOMID = @BomItemID
  return @resQ
end