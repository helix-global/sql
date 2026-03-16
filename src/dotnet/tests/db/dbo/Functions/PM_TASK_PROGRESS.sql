CREATE FUNCTION [dbo].[PM_TASK_PROGRESS](@LaborEst decimal(10,2), @LaborFact decimal(10,2), @mode int)
RETURNS int
AS
BEGIN
  
  if isnull(@LaborEst,0) <= 0
    return null
  
  declare @res int =  (isnull(@LaborFact,0) / @LaborEst) * 100
  
  if (isnull(@mode,0) <> 1 and  @res > 100)
    set @res = 100
  
  return @res

END