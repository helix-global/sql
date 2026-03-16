CREATE function [dbo].[MNT_NEXT_SNOOZE2](@aMntID int, @aEqID int)
returns datetime as 
begin
    
  return dbo.MNT_NEXT_SNOOZE3(@aMntID, @aEqID, null)
  
end