-- KB5300:2025-05-13: Refactoring. Added processing for "10 Years".
CREATE function [dbo].[MNT_NEXT_SNOOZE](@MntID int)
returns datetime as
begin
  declare @OutVal datetime
  declare @DBeg datetime
  declare @PeriodType int
  declare @Now datetime = getdate()
  declare @NowDate datetime = cast(@Now as date)

  select
     @DBeg = [a].[DBEG]
    ,@PeriodType = isnull([a].[SPERIOD],0)
  from [dbo].[MNT_PLAN] [a] with(nolock)
  where [a].[ID] = @MntID

  declare @DBegTime datetime
  set @DBegTime = cast(@DBeg as time)
  declare @Delta int

  if @DBeg > @Now
    return @DBeg

  if @PeriodType = 0
    return null
  else if @PeriodType = 10 /*Day*/
  begin
    set @OutVal = @NowDate + @DBegTime
    if @OutVal < @Now
      set @OutVal = dateadd(day,1,@OutVal)

    declare @dayOfWeek int
    set @dayOfWeek = (@@datefirst+datepart(weekday,@OutVal)-2)%7+1;
    if @dayOfWeek = 6
      set @OutVal = dateadd(day,2,@OutVal)
    else if @dayOfWeek = 7
      set @OutVal = dateadd(day,1,@OutVal)
  end
  else if @PeriodType = 20 /*Week*/
  begin
     set @Delta = datepart(weekday,@DBeg) - datepart(weekday,@NowDate)
     set @OutVal = dateadd(day,@Delta,@NowDate) + @DBegTime
     if @OutVal < @Now
       set @OutVal = dateadd(day,7,@OutVal)
  end
  else if @PeriodType = 30 /*Month*/
  begin
    set @Delta = datepart(day,@NowDate)
    set @OutVal = dateadd(day,-@Delta,@NowDate)
    set @Delta = datepart(day,@DBeg)
    set @OutVal = dateadd(day,@Delta,@OutVal)
    set @OutVal = @OutVal + @DBegTime
    if @OutVal < @Now
      set @OutVal = dateadd(month,1,@OutVal)
  end
  else if @PeriodType = 35 /* 2 month*/
  begin
    set @Delta = datepart(year,@NowDate) - datepart(year,@DBeg) 
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @Now
    begin
      set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @Now
        set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @Now
        set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @Now
        set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @Now
        set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @Now
        set @OutVal = dateadd(month,2,@OutVal)
    end
    else
    begin
      if dateadd(month,-2,@OutVal) > @Now
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @Now
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @Now
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @Now
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @Now
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @Now
        set @OutVal = dateadd(month,-2,@OutVal)
    end
  end
  else if @PeriodType = 40 /*Quarter*/
  begin
    set @Delta = datepart(year,@NowDate) - datepart(year,@DBeg)
    set @OutVal = dateadd(year,@Delta,@DBeg)
    set @Delta = datepart(month,@OutVal)
    if @Delta in (10,11,12)
      set @OutVal = dateadd(month,-9,@OutVal)
    else if @Delta in (7,8,9)
      set @OutVal = dateadd(month,-6,@OutVal)
    else if @Delta in (4,5,6)
      set @OutVal = dateadd(month,-3,@OutVal)

    if @OutVal < @Now
      set @OutVal = dateadd(month,3,@OutVal)
    if @OutVal < @Now
      set @OutVal = dateadd(month,3,@OutVal)
    if @OutVal < @Now
      set @OutVal = dateadd(month,3,@OutVal)
    if @OutVal < @Now
      set @OutVal = dateadd(month,3,@OutVal)
  end
  else if @PeriodType = 45 /*Half a Year*/
  begin
    set @Delta = datepart(year,@NowDate) - datepart(year,@DBeg)
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @Now
    begin
      set @OutVal = dateadd(month,6,@OutVal)
      if @OutVal < @Now
        set @OutVal = dateadd(month,6,@OutVal)
    end else
    begin
       if dateadd(month,-6,@OutVal) > @Now
         set @OutVal = dateadd(month,-6,@OutVal)
     end
  end
  else if @PeriodType = 50 /*Year*/
  begin
    set @Delta = datepart(year,@NowDate) - datepart(year,@DBeg)
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @Now
      set @OutVal = dateadd(year,1,@OutVal)
  end
  else if @PeriodType = 60 /*2 Years*/
  begin
    set @Delta = datepart(year,@NowDate) - datepart(year,@DBeg)
    if (@Delta % 2 = 1)
      set @Delta = @Delta + 1
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @Now
      set @OutVal = dateadd(year,2,@OutVal)
  end
  else if @PeriodType = 70 /*3 Years*/
  begin
    set @Delta = datepart(year,@NowDate) - datepart(year,@DBeg)
    declare @restvv int = @Delta % 3
    if (@restvv = 1)
      set @Delta = @Delta + 2
    else if (@restvv = 2)
      set @Delta = @Delta + 1
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @Now
      set @OutVal = dateadd(year,3,@OutVal)
  end
  else if @PeriodType = 80 /*4 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS](@Now,@DBeg,4)
  end
  else if @PeriodType = 90 /*5 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS](@Now,@DBeg,5)
  end
  else if @PeriodType = 100 /*6 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS](@Now,@DBeg,6)
  end
  else if @PeriodType = 110 /*7 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS](@Now,@DBeg,7)
  end else
  if @PeriodType = 120 /*8 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS](@Now,@DBeg,8)
  end else
  --KB5300
  if @PeriodType = 140 /*10 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS](@Now,@DBeg,10)
  end
  return @OutVal
end