CREATE function [dbo].[MNT_HIGHPRDATETIME](@aDate datetime,@Day int,@Hour int,@Minute int)
returns datetime as 
begin

  if isnull(@Day,0) = 0 and isnull(@Hour,0) = 0 and isnull(@Minute,0) = 0
    return null 
  
  declare @res datetime
  set @res = @aDate
  
  if isnull(@Day,0) <> 0
    set @res = dateadd(day,isnull(@Day,0),@res)

  if isnull(@Hour,0) <> 0
    set @res = dateadd(hour,isnull(@Hour,0),@res)

  if isnull(@Minute,0) <> 0
    set @res = dateadd(minute,isnull(@Minute,0),@res)
  
  
  if @res < @aDate
    return null
  
  return @res;
end