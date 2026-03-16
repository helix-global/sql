-- KB5300:2025-05-13: Refactoring. Added processing for "10 Years".
CREATE function [dbo].[MNT_NEXT_SNOOZE3](@aMntID int, @aEqID int, @OperationCompletionDate datetime)
returns datetime as 
begin
  declare @OutVal datetime
  declare @DBeg datetime
  declare @PeriodType int
  declare @aNow datetime = getdate()
  declare @nowDate datetime = cast(@aNow as date)
  declare @FromLastDate int
  declare @FromLastCompletionDate int
  declare @LastDate datetime 
  declare @HoliShiftMode int
  declare @LastDateFromEq datetime
  declare @CombinedPlanID int /*KB3982 если указан, LASTDATE брать из него если там значение больше*/
  declare @EqItemID int
  declare @MntID int

  set @MntID = @aMntID

  if @MntID is null
  begin
    select
      @MntID = [a].[VNESHID]
    from [dbo].[MNT_PLAN_EQ] [a] with(nolock)
    where [a].[ID] = @aEqID
  end

  select
     @DBeg = [a].[DBEG]
    ,@PeriodType = isnull([a].[SPERIOD],0)
    ,@FromLastDate = isnull([a].[SHIFTFROMLASTDATE],0)
    ,@FromLastCompletionDate = isnull([a].[SHIFTFROMLASTCMPLDATE],0)
    ,@LastDate = [a].[LASTDATE]
    ,@HoliShiftMode = isnull([a].[SHIFTHMODE],0)
    ,@CombinedPlanID = [a].[COMB_PLANID]
  from [dbo].[MNT_PLAN] [a] with(nolock)
  where [a].[ID] = @MntID

  if @aEqID is not null
  begin
    select
       @LastDate = isnull([a].[LASTDATE],[b].[LASTDATE])
      ,@LastDateFromEq = [a].[LASTDATE]
      ,@EqItemID = [a].[EQID]
    from [dbo].[MNT_PLAN_EQ] [a] with(nolock)
      left join [dbo].[MNT_PLAN] [b] with(nolock) on [b].[ID] = [a].[VNESHID]
    where [a].[ID] = @aEqID

    if @CombinedPlanID is not null /*KB3982*/
    begin
      declare @Second_LastDate datetime
      declare @Second_DateFromEq datetime

      select top 1
         @Second_LastDate = isnull([a].[LASTDATE],[b].[LASTDATE])
        ,@Second_DateFromEq = [a].[LASTDATE]
      from [dbo].[MNT_PLAN_EQ] [a] with(nolock)
        left join [dbo].[MNT_PLAN] [b] with(nolock) on [b].[ID]=[a].[VNESHID]
      where [b].[ID] = @CombinedPlanID
        and [a].[EQID] = @EqItemID

      if @Second_LastDate > @LastDate
        set @LastDate = @Second_LastDate
      if @Second_DateFromEq > @LastDateFromEq
        set @LastDateFromEq = @Second_DateFromEq
    end
  end

  /* время берем по плану несмотря на сдвиг */
  declare @DBegTime datetime  
  set @DBegTime = cast(@DBeg as time)

  /* если сдвиг включен - то отсчет от предыдущей даты */
  if (@FromLastDate = 1)
    set @DBeg = isnull(@LastDate,@DBeg)

  /* если сдвиг включен - то отсчет от предыдущей даты завершения операции*/
  if (@FromLastCompletionDate = 1)
    set @DBeg = isnull(@OperationCompletionDate,@DBeg)

  declare @Delta int

  if @DBeg > @aNow
    return @DBeg

  if @PeriodType = 0
    return null
  else if @PeriodType >= 10 AND @PeriodType<20 /*1-6 Days*/
  begin
    declare @Days int
    set @Days = @PeriodType - 9 /*кол-во дней зависит от @PeriodType (от 10 до 15)*/
    set @OutVal = @nowDate + @DBegTime

    if @OutVal < @aNow
      set @OutVal = dateadd(day,@Days,@OutVal) 
    if ([dbo].[DEF_SYS_CONST_STR]('com_remotelocation_code', '') <> 'IPM')
    begin
      declare @DayOfWeek int
      set @DayOfWeek = (@@datefirst+datepart(weekday,@OutVal)-2)%7+1;
      if @DayOfWeek = 6
        set @OutVal = dateadd(day,2,@OutVal)
      else if @DayOfWeek = 7
        set @OutVal = dateadd(day,1,@OutVal)
    end
  end
  else if @PeriodType = 20 /*Week*/
  begin
    set @Delta = datepart(weekday,@DBeg) - datepart(weekday,@nowDate)
    set @OutVal = dateadd(day,@Delta,@nowDate) + @DBegTime
    if @OutVal < @aNow
      set @OutVal = dateadd(day,7,@OutVal)
  end
  else if @PeriodType = 21 /*2 Weeks*/
  begin
    set @Delta = datepart(weekday,@DBeg) - datepart(weekday,@nowDate)
    set @OutVal = dateadd(day,@Delta,@nowDate) + @DBegTime
    if @OutVal < @aNow
      set @OutVal = dateadd(day,14,@OutVal) 
  end
  else if @PeriodType = 22 /*3 Weeks*/
  begin
    set @Delta = datepart(weekday,@DBeg) - datepart(weekday,@nowDate)
    set @OutVal = dateadd(day,@Delta,@nowDate) + @DBegTime
    if @OutVal < @aNow
      set @OutVal = dateadd(day,21,@OutVal)
  end
  else if @PeriodType = 24 /*5 Weeks*/
  begin
    set @Delta = datepart(weekday,@DBeg) - datepart(weekday,@nowDate)
    set @OutVal = dateadd(day,@Delta,@nowDate) + @DBegTime
    if @OutVal < @aNow
      set @OutVal = dateadd(day,35,@OutVal)
  end
  else if @PeriodType = 30 /*Month*/
  begin
    set @Delta = datepart(day,@nowDate)
    set @OutVal = dateadd(day,-@Delta,@nowDate)
    set @Delta = datepart(day,@DBeg)
    set @OutVal = dateadd(day,@Delta,@OutVal)
    set @OutVal = @OutVal + @DBegTime
    if @OutVal < @aNow
      set @OutVal = dateadd(month,1,@OutVal) 

    if @LastDateFromEq is not null /*KB2232*/
      if (cast(@OutVal as date) <= cast(@LastDateFromEq as date))
        set @OutVal = dateadd(month,1,@OutVal) 
    if datediff(day,cast(@OperationCompletionDate as date),cast(@OutVal as date)) < 2
        set @OutVal = dateadd(month,1,@OutVal)
  end
  else if @PeriodType = 35 /* 2 month*/
  begin
    set @Delta = datepart(year,@nowDate) - datepart(year,@DBeg) 
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @aNow
    begin
      set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @aNow
        set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @aNow
        set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @aNow
        set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @aNow
        set @OutVal = dateadd(month,2,@OutVal)
      if @OutVal < @aNow
        set @OutVal = dateadd(month,2,@OutVal)
    end
    else
    begin
      if dateadd(month,-2,@OutVal) > @aNow
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @aNow
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @aNow
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @aNow
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @aNow
        set @OutVal = dateadd(month,-2,@OutVal)
      if dateadd(month,-2,@OutVal) > @aNow
        set @OutVal = dateadd(month,-2,@OutVal)
    end
  end
  else if @PeriodType = 40 /*Quarter*/
  begin
    set @Delta = datepart(year,@nowDate) - datepart(year,@DBeg)
    set @OutVal = dateadd(year,@Delta,@DBeg)
    set @Delta = datepart(month,@OutVal)
    if @Delta in (10,11,12)
      set @OutVal = dateadd(month,-9,@OutVal)
    else if @Delta in (7,8,9)
      set @OutVal = dateadd(month,-6,@OutVal)
    else if @Delta in (4,5,6)
      set @OutVal = dateadd(month,-3,@OutVal)

    if @OutVal < @aNow
      set @OutVal = dateadd(month,3,@OutVal)
    if @OutVal < @aNow
      set @OutVal = dateadd(month,3,@OutVal)
    if @OutVal < @aNow
      set @OutVal = dateadd(month,3,@OutVal)
    if @OutVal < @aNow
      set @OutVal = dateadd(month,3,@OutVal)
  end
  else if @PeriodType = 42 /*4 Month*/
  begin
    set @Delta = datepart(year,@nowDate) - datepart(year,@DBeg)
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @aNow
    begin
      set @OutVal = dateadd(month,4,@OutVal)
      if @OutVal < @aNow
        set @OutVal = dateadd(month,4,@OutVal)
      if @OutVal < @aNow
      set @OutVal = dateadd(month,4,@OutVal)
    end
    else
    begin
      if dateadd(month,-4,@OutVal) > @aNow
        set @OutVal = dateadd(month,-4,@OutVal)
    end
    if @OutVal < @aNow
      set @OutVal = dateadd(month,4,@OutVal)
    if @OutVal < @aNow
      set @OutVal = dateadd(month,4,@OutVal)
  end
  else if @PeriodType = 45 /*Half a Year*/
  begin
    set @Delta = datepart(year,@nowDate) - datepart(year,@DBeg)
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @aNow
    begin
      set @OutVal = dateadd(month,6,@OutVal)
      if @OutVal < @aNow
        set @OutVal = dateadd(month,6,@OutVal)
    end
    else
    begin
      if dateadd(month,-6,@OutVal) > @aNow
        set @OutVal = dateadd(month,-6,@OutVal)
    end
  end
  else if @PeriodType = 47 /*8 Month*/   --KB3310
  begin
    set @Delta = datepart(year,@nowDate) - datepart(year,@DBeg)
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @aNow
    begin
      set @OutVal = dateadd(month,8,@OutVal)
      if @OutVal < @aNow
        set @OutVal = dateadd(month,8,@OutVal)
    end
    else
    begin
      if dateadd(month,-8,@OutVal) > @aNow
        set @OutVal = dateadd(month,-8,@OutVal)
    end
  end
  else if @PeriodType = 50 /*Year*/
  begin
    set @Delta = datepart(year,@nowDate) - datepart(year,@DBeg)
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @aNow
      set @OutVal = dateadd(year,1,@OutVal)
       
    if @OperationCompletionDate is not null
      if datediff(day,cast(@OperationCompletionDate as date),cast(@OutVal as date)) < 2
          set @OutVal = dateadd(year,1,@OutVal)
  end
  else if @PeriodType = 60 /*2 Years*/
  begin
    set @Delta = datepart(year,@nowDate) - datepart(year,@DBeg)
    if (@Delta % 2 = 1)
      set @Delta = @Delta + 1
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @aNow
      set @OutVal = dateadd(year,2,@OutVal)
       
    if @OperationCompletionDate is not null
      if datediff(day,cast(@OperationCompletionDate as date),cast(@OutVal as date)) < 2
          set @OutVal = dateadd(year,2,@OutVal)
  end
  else if @PeriodType = 70 /*3 Years*/
  begin
    set @Delta = datepart(year,@nowDate) - datepart(year,@DBeg)
    declare @restvv int = @Delta % 3
    if (@restvv = 1)
      set @Delta = @Delta + 2
    else if (@restvv = 2)
      set @Delta = @Delta + 1
    set @OutVal = dateadd(year,@Delta,@DBeg)
    if @OutVal < @aNow
      set @OutVal = dateadd(year,3,@OutVal)

    if @OperationCompletionDate is not null
      if datediff(day,cast(@OperationCompletionDate as date),cast(@OutVal as date)) < 2
        set @OutVal = dateadd(year,3,@OutVal) 
  end
  else if @PeriodType = 80 /*4 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS2](@aNow,@DBeg,4,@OperationCompletionDate)
  end
  else if @PeriodType = 90 /*5 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS2](@aNow,@DBeg,5,@OperationCompletionDate)
  end
  else if @PeriodType = 100 /*6 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS2](@aNow,@DBeg,6,@OperationCompletionDate)
  end
  else if @PeriodType = 110 /*7 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS2](@aNow,@DBeg,7,@OperationCompletionDate)
  end
  else if @PeriodType = 120 /*8 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS2](@aNow,@DBeg,8,@OperationCompletionDate)
  end
  --KB5300
  else if @PeriodType = 140 /*10 Years*/
  begin
    set @OutVal = [dbo].[MNT_NEXT_SNOOZE_YEARS2](@aNow,@DBeg,10,@OperationCompletionDate)
  end
  if @OutVal is not null and @HoliShiftMode > 0
  begin
    set @OutVal = [dbo].[MNT_NEXT_SHIFT_HOLIDAY](@OutVal,@HoliShiftMode)
  end
  return @OutVal
end