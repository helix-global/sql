CREATE function [dbo].[PR_EXP_WEEK_FRMT](@aDate datetime,@aNow datetime,@aCompleted datetime,@aReserved int)
returns nvarchar(10) WITH SCHEMABINDING as
begin
  if @aCompleted is not null 
    return null
    
  declare @week int
  set @week = DATEPART(week,@aDate)
  
  if datediff(day,@aNow,@aDate) <= 0 
    return '!!!'
  
  if datediff(day,@aNow,@aDate) <= 7  
    return '!!'

  if datediff(WEEK,@aNow,@aDate) <= 3  
    return '!'
  
  return null
end