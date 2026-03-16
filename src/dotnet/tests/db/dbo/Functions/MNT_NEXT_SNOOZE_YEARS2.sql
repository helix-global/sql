CREATE function [dbo].[MNT_NEXT_SNOOZE_YEARS2](@aNow datetime, @dbeg datetime, @aYears int, @OperationCompletionDate datetime)
returns datetime with schemabinding as 
begin
  
  declare @res datetime
  declare @nowDate datetime = cast(@aNow as date)
  
  declare @delta int
  set @delta = datepart(year,@nowDate) - datepart(year,@dbeg) 
 
  declare @restvv int = @delta % @aYears
  
  if (@restvv > 0)
       set @delta = @delta + (@aYears - @restvv)
       
  set @res = dateadd(year,@delta,@dbeg)
  
  if @res < @aNow
      set @res = dateadd(year,@aYears,@res) 

  if @OperationCompletionDate is not null
     if datediff(day,cast(@OperationCompletionDate as date),cast(@res as date)) < 2
        set @res = dateadd(year,@aYears,@res) 
  
  return @res;
end