CREATE function [dbo].[PR_IMP_TIME2LOAD](@LastDate datetime, @LoadTime datetime)
returns int with schemabinding as 
begin

  declare @now datetime = getdate()
  
  declare @nextTime datetime
  if @LastDate is null
     set @nextTime = cast(@now as date)
  else
  begin
     set @nextTime = cast(@LastDate as date)
     set @nextTime = dateadd(day,1,@nextTime)
  end  
  
  set @nextTime = @nextTime + cast(cast(@LoadTime as time) as datetime)
  if @nextTime < @now
     return 1

  return 0
  
end