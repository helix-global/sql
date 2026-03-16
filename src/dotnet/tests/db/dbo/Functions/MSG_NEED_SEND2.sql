CREATE function [dbo].[MSG_NEED_SEND2](@aLastSend datetime,@aPeriodMode int,@shortPeriodMode int,@sendAt datetime,@aNow datetime)
returns int as 
begin

  if @aLastSend is null
    return 1

/*
@aPeriodMode:   
1	Every Month Begin
2	Every Month Begin + 7 days
3	Every Work Day 8:00
4   Every Friday 17:00
5   Every Thursday 17:00
6   Every Wednesday 17:00
7   Every Tuesday 17:00
8   Every Monday 17:00
9 	Every Work Day 17:05
10	Every Work Day 16:00
*/

/*
@shortPeriodMode:   
1	Every Month Begin
2	Every Month Begin + 7 days
3	Every Work Day
4 Every Friday
5 Every Thursday
6 Every Wednesday
7 Every Tuesday
8 Every Monday

21,22  KB3545
*/

  declare @dayOfWeek int
  set @dayOfWeek = (@@datefirst+datepart(weekday,@aNow)-2)%7+1; 

  if (@aPeriodMode = 1)
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and (MONTH(@aLastSend) <> MONTH(@aNow) or Year(@aLastSend) <> Year(@aNow))
       and DATEPART(hour,@aNow) >= 8 
      return 1
  end
  else if (@aPeriodMode = 2)
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and (MONTH(@aLastSend) <> MONTH(@aNow) or Year(@aLastSend) <> Year(@aNow))
       and DATEPART(hour,@aNow) >= 8 
       and DATEPART(DAY,@aNow) > 7 
      return 1
  end
  else if (@aPeriodMode = 3)
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= 8 
       return 1
  end
  else if (@aPeriodMode = 4)
  begin
      if @dayOfWeek = 5
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= 17 
       return 1
  end
  else if (@aPeriodMode = 5)
  begin
      if @dayOfWeek = 4
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= 17 
       return 1
  end
  else if (@aPeriodMode = 6)
  begin
      if @dayOfWeek = 3
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= 17 
       return 1
  end
  else if (@aPeriodMode = 7)
  begin
      if @dayOfWeek = 2
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= 17 
       return 1
  end
  else if (@aPeriodMode = 8)
  begin
      if @dayOfWeek = 1
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= 17 
       return 1
  end
  else if (@aPeriodMode = 9)
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= 17 
       and DATEPART(minute,@aNow) >= 5 
       return 1
  end
  else if (@aPeriodMode = 10)
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= 16 
       return 1
  end

  set @sendAt = isnull(@sendAt, cast('8:00:00' as datetime))

  if (@shortPeriodMode = 1)
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and (MONTH(@aLastSend) <> MONTH(@aNow) or Year(@aLastSend) <> Year(@aNow))
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
      return 1
  end
  else if (@shortPeriodMode = 2)
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and (MONTH(@aLastSend) <> MONTH(@aNow) or Year(@aLastSend) <> Year(@aNow))
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
       and DATEPART(DAY,@aNow) > 7 
      return 1
  end
  else if (@shortPeriodMode = 3)
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
       return 1
  end
  else if (@shortPeriodMode = 4)
  begin
      if @dayOfWeek = 5
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
       return 1
  end
  else if (@shortPeriodMode = 5)
  begin
      if @dayOfWeek = 4
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
       return 1
  end
  else if (@shortPeriodMode = 6)
  begin
      if @dayOfWeek = 3
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
       return 1
  end
  else if (@shortPeriodMode = 7)
  begin
      if @dayOfWeek = 2
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
       return 1
  end
  else if (@shortPeriodMode = 8)
  begin
      if @dayOfWeek = 1
       and cast(@aLastSend as date) < cast(@aNow as date)
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
       return 1
  end  
  else if (@shortPeriodMode = 21) /*KB3545*/
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and (MONTH(@aLastSend) <> MONTH(@aNow) or Year(@aLastSend) <> Year(@aNow))
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
       and DATEPART(DAY,@aNow) > 2 
      return 1
  end  
  else if (@shortPeriodMode = 22)  /*KB3545*/
  begin
    if dbo.COM_IS_WORKDAY(@aNow,1) = 1 
       and (MONTH(@aLastSend) <> MONTH(@aNow) or Year(@aLastSend) <> Year(@aNow))
       and DATEPART(hour,@aNow) >= datepart(hour,@sendAt) 
       and DATEPART(minute,@aNow) >= datepart(minute,@sendAt) 
       and DATEPART(DAY,@aNow) > 4 
      return 1
  end    
  

  return 0;
  
end