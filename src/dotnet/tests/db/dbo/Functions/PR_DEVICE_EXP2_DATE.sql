create function [dbo].[PR_DEVICE_EXP2_DATE](@DeviceID int,@DeviceSS int, @SupplyOrdD datetime, @OrdD datetime)
returns datetime as 
begin

  if @DeviceSS in (1000085/*shipped*/,1000030/*shipped*/,1000077/*installed*/,1000081/*uninstall*/,1000086/*inst.cancel*/)
    return null

  if @DeviceSS in (1000011/*inserv*/,1000039/*srv.cmpl*/)
  begin
  
     declare @expD_from_ServOrd datetime
     select top 1 @expD_from_ServOrd = FS.EXPDATE from PR_PRORDER FS with (nolock) where FS.ID in (select FST.ORDERID from PR_PRORDER_SERVICE FST with (nolock) where FST.DEVICEID = @DeviceID) order by FS.ID desc
     return @expD_from_ServOrd
  
  end
  
  return isnull(@SupplyOrdD, @OrdD)

end