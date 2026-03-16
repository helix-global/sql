CREATE function [dbo].[PR_OPER_URGENCY2](@aOperOrderID int,@aPrOrderID int,@aPrOrderUrgency int, @aSupplyOrdUrgency int )
returns int with schemabinding as 
begin

  if (@aOperOrderID = @aPrOrderID)
  begin
     
     return isnull(@aSupplyOrdUrgency,@aPrOrderUrgency)
  
  end
  else
  begin

     return @aPrOrderUrgency
  
  end   

  return null
  
end