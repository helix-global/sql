CREATE function [dbo].[PR_DEVICE_STAT](@DeviceID int, @OrderID int, @aMode int, @now datetime)
returns int
as
begin
  
   declare @resD decimal(12,2)
   set @resD = dbo.PR_DEVICE_STAT_DEC(@DeviceID,@OrderID,@aMode,@now)
   set @resD = round(@resD,0)
   return @resD
  
end;