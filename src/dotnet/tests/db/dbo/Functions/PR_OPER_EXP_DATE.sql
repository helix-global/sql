create function [dbo].[PR_OPER_EXP_DATE](@OrderType int, @SupplyOrderDD datetime, @CurrentOrderDD datetime)
returns datetime with schemabinding as 
begin

  if isnull(@OrderType,0) = 0 and @SupplyOrderDD is not null
     return @SupplyOrderDD
  
  return @CurrentOrderDD

end