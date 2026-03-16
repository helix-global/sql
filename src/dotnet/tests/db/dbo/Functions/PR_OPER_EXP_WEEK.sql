CREATE function [dbo].[PR_OPER_EXP_WEEK](@OrderType int, @SupplyOrderDD datetime, @CurrentOrderDD datetime)
returns int with schemabinding as 
begin

  if isnull(@OrderType,0) = 0 and @SupplyOrderDD is not null
     return datepart(isowk,@SupplyOrderDD)
  
  return datepart(isowk,@CurrentOrderDD)

end