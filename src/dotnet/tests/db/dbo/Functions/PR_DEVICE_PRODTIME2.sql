CREATE function [dbo].[PR_DEVICE_PRODTIME2](@DeviceID int, @DeviceCmpl datetime, @OrderID int, @now datetime)
returns int WITH SCHEMABINDING
as
begin
   declare @res int
   if @DeviceCmpl is null
   begin
   
       declare @dbeg datetime
       
       select @dbeg = min(A.DBEG) 
         from dbo.PR_OPERATION B with (nolock)
         left join dbo.PR_OPERATION_TIME A with (nolock) on A.OPERID = B.ID
        where B.DEVICEID = @DeviceID 
          and B.ORDERID = @OrderID
          
       set @res = datediff(minute,@dbeg,@now)
       if (@res < 0)
          set @res = 0
        
   end
   else
     select @res = A.CYCLEFROM1OPER from dbo.PR_DEVICE_STATVALUES A with (nolock) where A.DEVICEID = @DeviceID and A.ORDERID = @OrderID
   
   return @res  
end;