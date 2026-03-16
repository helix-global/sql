create function [dbo].[PR_SERVICE_ORDER_SNS](@aOrderID int)
returns nvarchar(max)
as
begin

  declare @res nvarchar(max)
  set @res = '';
  select @res = @res + B.SN + ', '
  from PR_PRORDER_SERVICE A with (nolock)
  left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
  where A.ORDERID = @aOrderID
    
  if LEN(LTRIM(@res)) = 0
    return null  
    
  declare @reslen int
  set @reslen = len(@res)
  if @reslen > 2
    set @res = SUBSTRING(@res,1,@reslen-1)

  return @res;
end;