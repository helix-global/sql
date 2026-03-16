CREATE function [dbo].[PR_SUPPLY_REST_QTY](@aSOrdID int, @aInQty decimal(18,4) )
returns decimal(18,4) as 
begin
  
  if @aInQty is null
    return null

  declare @ShippedQ decimal(18,4)  
  
  select @ShippedQ = sum(isnull(A.RESQUANTITY,1))
  from PR_DEVICE A with (nolock)
  where A.SORDERID = @aSOrdID
    and A.SHIPPED_DT is not null 
    and A.S_S not in (1000101/*canceled*/,1000078/*failed*/) /*KB375*/
  
  set @ShippedQ = isnull(@ShippedQ,0)
  
  if @ShippedQ > @aInQty
    return 0;
  
  return @aInQty - @ShippedQ;  

end