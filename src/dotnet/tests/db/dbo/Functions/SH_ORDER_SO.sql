CREATE function [dbo].[SH_ORDER_SO](@aOrderID int)
returns nvarchar(max)
as
begin

  declare @res nvarchar(max)
  set @res = '';
  select @res = @res + SO + ', ' from (
  select distinct isnull(C.ND,D.NN2) as SO
  from SH_ORDER_T A with (nolock)
  left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
  left join PR_SUPPLY C with (nolock) on C.ID = B.SORDERID
  left join PR_PRORDER D with (nolock) on D.ID = B.ORDERID
  where A.SHORDERID = @aOrderID
  ) M
    
  if LEN(LTRIM(@res)) = 0
    return null  
    
  declare @reslen int
  set @reslen = len(@res)
  if @reslen > 2
    set @res = SUBSTRING(@res,1,@reslen-1)

  return @res;
end;