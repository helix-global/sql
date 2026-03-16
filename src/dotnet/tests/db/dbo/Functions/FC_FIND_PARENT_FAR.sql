CREATE function [dbo].[FC_FIND_PARENT_FAR](@aOrderID int,@aDeviceID int)
returns int as 
begin

  declare @res int

  select @res = A.FRID 
  from PR_PRORDER_SERVICE A with (nolock)
  left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
  where A.ORDERID = @aOrderID
    and A.DEVICEID = @aDeviceID
    and B.ORDERTYPE = 1
  
  return @res;
end