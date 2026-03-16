
create function [dbo].[PR_DEVICE_LAST_SERV_ORDER](@aDeviceID int, @aMode int)
returns int
as
begin

  declare @lastSrvOrderID int
  
  select top 1 @lastSrvOrderID = A.ORDERID
  from PR_PRORDER_SERVICE A with (nolock)
  left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
  where A.DEVICEID = @aDeviceID
    and B.ORDERTYPE = 1  /*srv*/
  order by A.ID desc

  return @lastSrvOrderID

end;