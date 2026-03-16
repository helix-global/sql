CREATE function [dbo].[PR_DEVICE_LAST_ORDER_N](@aDeviceID int, @aMode int)
returns nvarchar(50)
as
begin
/* 
@aMode 1 - возвращает или номер произв заказа или номер сервисного заказа последнего по изделию
@aMode 2 - возвращает или номер продажного заказа или номер сервисного заказа последнего по изделию
*/

  declare @lastSrvOrderID int
  declare @lastSrvOrderNN nvarchar(50)
  
  select top 1 @lastSrvOrderID = A.ORDERID, @lastSrvOrderNN = B.NN
  from PR_OPERATION A with (nolock)
  left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
  where A.DEVICEID = @aDeviceID
    and B.ORDERTYPE = 1  /*srv*/
  order by A.ID desc
  
  if @aMode = 1
    if @lastSrvOrderID is not null
      return @lastSrvOrderNN
  
  declare @prodOrderNN nvarchar(50)
  declare @soOrderNN nvarchar(50)
  
  select @prodOrderNN = B.NN
       , @soOrderNN = isnull(C.ND,B.NN2)
  from PR_DEVICE A with (nolock) 
  left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
  left join PR_SUPPLY C with (nolock) on C.ID = A.SORDERID
  where A.ID = @aDeviceID

  if @aMode = 1
     return @prodOrderNN
     
  if @aMode = 2
     return @soOrderNN
    
    
  return null
end;