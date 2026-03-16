CREATE function [dbo].[PR_EXP_WEEK_FRMT2](@aDate datetime,@aNow datetime,@aCompleted datetime,@aLastServOrd int,@DeviceSS int)
returns nvarchar(10) with schemabinding  as
begin

  if @aLastServOrd is null and @aCompleted is not null 
    return null
    
  if @aLastServOrd is not null and @DeviceSS not in (1000011/*in serv*/,1000100/*srv.postponed*/)
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