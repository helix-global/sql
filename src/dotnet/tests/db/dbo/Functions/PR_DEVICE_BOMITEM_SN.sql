create function [dbo].[PR_DEVICE_BOMITEM_SN](@DeviceID int, @BomItemID int,@aMode int)
returns nvarchar(100) as 
begin
  declare @resSN nvarchar(100)
  select top 1 @resSN = A.SN from PR_DEVICE_BOM A where A.DEVICEID = @DeviceID and A.UNINSTALLOPERID is null and A.BOMID = @BomItemID
  return @resSN
end