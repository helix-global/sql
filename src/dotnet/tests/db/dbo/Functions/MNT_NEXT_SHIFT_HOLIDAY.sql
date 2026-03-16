CREATE function [dbo].[MNT_NEXT_SHIFT_HOLIDAY](@aDate datetime, @shiftMode int)
returns datetime as 
begin
  
  if isnull(@shiftMode,0) = 0
    return @aDate
  
  declare @res datetime 
  set @res = @aDate
  
  while 1=1
  begin
    declare @dayOfWeek int
    set @dayOfWeek = (@@datefirst+datepart(weekday,@res)-2)%7+1; 
    
    if @shiftMode = 1 /* Shift on Holidays, Saturday, Sunday */
    begin
      
      if @dayOfWeek in (1,2,3,4,5) and dbo.COM_IS_WORKDAY(@res,1) = 1
        break 
      
    end
    else
      break
    
    set @res = dateadd(day,1,@res)
    
  end
  
  return @res
  
end