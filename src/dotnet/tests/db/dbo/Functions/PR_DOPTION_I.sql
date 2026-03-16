create function [dbo].[PR_DOPTION_I](@DeviceID int, @OptionN int, @Mode int)
returns decimal(16,4) as 
begin
   
  declare @optQty int
   
  select top 1 @optQty = A.QUANTITY
  from PR_DEVICE_OPT A with (nolock) 
  where A.DEVICEID = @DeviceID
    and (select COUNT(*) from PR_DEVICE_OPT N with (nolock) where N.DEVICEID = @DeviceID and N.ID < A.ID) = @OptionN - 1
   
     
  return @optQty 
   
end