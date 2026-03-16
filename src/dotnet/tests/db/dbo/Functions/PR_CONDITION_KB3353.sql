CREATE function [dbo].[PR_CONDITION_KB3353](@deviceID int, @paramID int, @more int,@moreValue float,@less int,@lessValue float)
returns int as 
/* KB3353 */
begin
  
  if isnull(@paramID,0) < 1
     return 1
     
  if isnull(@more,0) = 0 and isnull(@less,0) = 0
     return 1  

  declare @aValue float
  
  set @aValue = dbo.PR_DEVICE_PARAM_FLOAT2(@deviceID, @paramID)
  
  if @aValue is null
    return 0
    
  if isnull(@more,0) = 1 and @aValue <= @moreValue
    return 0
    
  if isnull(@less,0) = 1 and @aValue >= @lessValue
    return 0
  
  return 1

end