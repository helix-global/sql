CREATE function [dbo].[PR_IMP_TIME2LOAD2](@LastDate datetime, @LoadTime datetime)
returns int with schemabinding as 
begin

  declare @now datetime = getdate()
  
  declare @nextTime datetime
  set @nextTime = cast(@now as date)
  set @nextTime = @nextTime + cast(cast(@LoadTime as time) as datetime)
  
  if @LastDate < @nextTime and @now > @nextTime
     return 1

  return 0
  
end