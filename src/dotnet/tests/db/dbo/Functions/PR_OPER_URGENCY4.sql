create function [dbo].[PR_OPER_URGENCY4](@aOperOrderID int,@aPrOrderID int,@aPrOrderUrgency int, @aSupplyOrdUrgency int, @aOperUrgency int )
returns int with schemabinding as 
begin
  if @aOperUrgency is not null
    return @aOperUrgency


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