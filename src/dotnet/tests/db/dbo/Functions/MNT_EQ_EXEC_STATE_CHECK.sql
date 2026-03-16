create function [dbo].[MNT_EQ_EXEC_STATE_CHECK](@aS_S int,@aSetting int)
returns int as 
begin
  
  if isnull(@aSetting,0) = 0 and @aS_S in (1000173, 1000174, 2130044) /*in use, reserve, in calibration*/
    return 1
    
  if @aSetting = 10  and @aS_S in (1000173,1000174) 
    return 1
    
  if @aSetting = 20 and @aS_S in (1000173) 
    return 1
    
  if @aSetting = 30 and @aS_S in (1000174)
    return 1

  if @aSetting = 40 and @aS_S in (1000173, 2130044)
    return 1

  if @aSetting = 50 and @aS_S in (1000173, 1000174, 2000017, 2000014)
    return 1
    
  if @aSetting = 100 /*all states*/
    return 1
  
  return 0;
end