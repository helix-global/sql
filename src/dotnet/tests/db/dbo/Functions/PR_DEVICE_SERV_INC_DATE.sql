create function [dbo].[PR_DEVICE_SERV_INC_DATE](@aDeviceID int, @aMode int)
returns date 
as
begin

/*  KB931 service order incoming date */

  declare @res date
  
  select top 1 @res = cast(A.INC_DATE as date)
  from PR_PRORDER_SERVICE A with (nolock)
  left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
  where A.DEVICEID = @aDeviceID
  order by B.ID desc 
    
  return @res
end;