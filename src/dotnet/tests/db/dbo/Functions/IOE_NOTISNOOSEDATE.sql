create function [dbo].[IOE_NOTISNOOSEDATE](@aDD date, @PeriodType int, @Period int)
returns date as 
begin

  declare @result date
  set @result = dateadd(day,1,@aDD)
  
  if @Period > 0 
  begin

	if @PeriodType = 10 /*day*/ 
	     set @result = dateadd(day,@Period,@aDD)
    else if @PeriodType = 20 /*week*/    
		set @result = dateadd(day,@Period*7,@aDD)
    else if @PeriodType = 50 /*year*/    
		set @result = dateadd(year,@Period,@aDD)
  
  end
   
  
  return @result

end