CREATE function [dbo].[COM_PERCENTAGE](@aAll decimal(20,4),@aPart decimal(20,4),@aRoundTo int)
returns decimal(20,4) with schemabinding as 
begin
  declare @res decimal(20,4)
  
  if @aAll > 0
    set @res = (@aPart / @aAll) * 100
  
  if @aRoundTo is not null
    set @res = ROUND(@res,@aRoundTo)
  
  return @res;
end