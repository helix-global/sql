create function [dbo].[PR_DEVICE_PRODTIME](@DeviceID int, @DeviceState int, @OrderID int, @now datetime)
returns int
as
begin

   if @DeviceState not in (1000008,1000022) /*in production, production completed*/
     return null
   /*может сохранять значение в поле ?*/
   
   declare @res int
   declare @dbeg datetime
   declare @dend datetime
   
   select @dbeg = min(A.DBEG) from PR_OPERATION_TIME A with (nolock) where A.OPERID in (select B.ID from PR_OPERATION B where B.DEVICEID = @DeviceID and B.ORDERID = @OrderID)
   select @dend = isnull(A.COMPLETED_DT,@now) from PR_DEVICE A with (nolock) where A.ID = @DeviceID
      
   set @res = datediff(minute,@dbeg,@dend)
   if (@res < 0)
      set @res = 0
        
   return @res  
end;