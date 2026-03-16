create function [dbo].[PR_DEVICE_BOMITEM_MODELNAME](@DeviceID int, @BomItemID int,@aMode int)
returns nvarchar(200) as 
begin
  declare @resSN nvarchar(200)
  select top 1 @resSN = A.MODELNAME from PR_DEVICE_BOM A where A.DEVICEID = @DeviceID and A.BOMID = @BomItemID and A.UNINSTALLOPERID is null 
  return @resSN
end