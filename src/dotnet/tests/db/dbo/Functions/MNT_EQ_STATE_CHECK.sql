CREATE function [dbo].[MNT_EQ_STATE_CHECK](@aS_S int,@aSetting int)
returns int with schemabinding as 
begin
  
  if isnull(@aSetting,0) = 0 /*both*/ and @aS_S in (1000173, 1000174) /*in use or reserve*/
    return 1
    
  if @aSetting = 1 /*only in use*/ and @aS_S in (1000173) /*in use*/
    return 1
    
  if @aSetting = 2 /*only reserve*/ and @aS_S in (1000174) /*reserve*/
    return 1
    
  if @aSetting = 3 /*"In Use","Reserved","Defect" and "In Repair"*/ and @aS_S in (1000173,1000174,2000017,2000014)/*in use,reserve,defect,in repair*/
    return 1
    
  if @aSetting = 100 /*all states*/
    return 1
  
  return 0;
end