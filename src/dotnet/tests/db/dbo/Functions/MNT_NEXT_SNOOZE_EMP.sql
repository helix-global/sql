-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-07-25
-- Description: Calculates proposed value for [NEXTDATE] for maintenance plan and associated employee.
-- =============================================
-- KB4896:2024-07-25: Initial update.
-- KB5300:2025-05-13: Refactoring. Added processing for "10 Years".
CREATE function [dbo].[MNT_NEXT_SNOOZE_EMP](@MntID int,@EmpID int)
returns datetime as
begin
  if (@MntID is null) or (@EmpID is null) return null
  declare @D datetime = null
  declare @MntPeriodType int = 0
  declare @MntBegTimeA datetime = null
  declare @MntBegTimeB datetime = null
  declare @MntPLBegDate datetime = null
  declare @MntPLLstDate datetime = null
  declare @MntEMLstDate datetime = null
  declare @Delta int = 0
  declare @MntShiftHMode int = 0
  declare @MntNDShiftMode int = 0
  declare @MntState int = 1
  declare @UserID int

  select top 1 @UserID=[u].[ID] from [dbo].[DEF_USERS] [u] with(nolock) where [u].[EMPLOYEEID]=@EmpID

  -- Initialising data from [MNT_PLAN]
  select
     @MntPeriodType=[p].[SPERIOD]
    ,@MntPLBegDate=[p].[DBEG]
    ,@MntBegTimeA=cast([p].[DBEG] as time)
    ,@MntPLLstDate=[p].[LASTDATE]
    ,@MntNDShiftMode=[dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE]([p].[ID])
    ,@MntShiftHMode = isnull([p].[SHIFTHMODE],0)
  from [dbo].[MNT_PLAN] [p] with(nolock)
  where [p].[ID]=@MntID

  select
    @MntEMLstDate=max([o].[COMPLETED_DT])
  from [dbo].[MNT_PLAN] [p] with(nolock)
    inner join [dbo].[PR_OPERATION] [o] with(nolock) on [o].[MNT_PLANID]=[p].[ID]
  where [p].[ID]=@MntID
    and coalesce([o].[USERINPROGRESS],[o].[FORCEUSERINPROGRESS],[o].[USERINTRAINING],[o].[S_MR])=@UserID
    and [o].[OPERTYPEID]=[p].[OPERID]

  set @MntPLLstDate = isnull(@MntEMLstDate,@MntPLLstDate)

  if @MntPeriodType = 0 return null
  if @MntState=0        return null

  -- Calculation period rules.
  declare @PeriodCalcT table([SPERIOD] int,[UNIT] varchar(1),[VALUE] int
    ,[B] int, [DAYS] float, unique clustered ([SPERIOD]))
  insert into @PeriodCalcT
    select  10,'d', 1,0,   1.00 union all
    select  11,'d', 2,0,   2.00 union all
    select  12,'d', 3,0,   3.00 union all
    select  13,'d', 4,0,   4.00 union all
    select  14,'d', 5,0,   5.00 union all
    select  15,'d', 6,0,   6.00 union all
    select  20,'w', 1,0,   7.00 union all
    select  21,'w', 2,0,  14.00 union all
    select  22,'w', 3,0,  21.00 union all
    select  24,'w', 5,0,  35.00 union all
    select  30,'m', 1,0,  30.42 union all
    select  35,'m', 2,0,  60.83 union all
    select  40,'m', 3,1,  91.25 union all
    select  42,'m', 4,1, 121.67 union all
    select  45,'m', 6,1, 182.50 union all
    select  47,'m', 8,1, 243.33 union all
    select  50,'y', 1,1, 365.00 union all
    select  60,'y', 2,1, 730.00 union all
    select  70,'y', 3,1,1095.00 union all
    select  80,'y', 4,1,1461.00 union all
    select  90,'y', 5,1,1826.00 union all
    select 100,'y', 6,1,2191.00 union all
    select 110,'y', 7,1,2556.00 union all
    select 120,'y', 8,1,2922.00 union all
    select 140,'y',10,1,3650.00 union all --KB5300
    select 100000,'c',0,0,0.0

  declare @UseTimeFractionFromB int = 0
  declare @PeriodUnit  varchar(1)
  declare @PeriodValue int
  declare @PeriodDays float
  select
     @PeriodUnit=[UNIT]
    ,@PeriodValue=[VALUE]
    ,@UseTimeFractionFromB=[B]
    ,@PeriodDays=[DAYS]
  from @PeriodCalcT
  where [SPERIOD]=@MntPeriodType

  declare @NowT datetime = getdate()

  if @MntNDShiftMode=1     set @MntPLBegDate=isnull(@MntPLLstDate,@MntPLBegDate)
  if @MntNDShiftMode=2
  begin
    set @MntPLBegDate=coalesce(@MntEMLstDate,@MntPLBegDate)
    set @UseTimeFractionFromB = 0

    -- Sets "@Now" as date from past for specified employee if it associated
    -- with completed operation.
    if (@MntEMLstDate is not null)
    begin
      set @NowT = @MntEMLstDate
    end
  end

  declare @NowD datetime = cast(@NowT as date)
  set @MntBegTimeB=cast(@MntPLBegDate as time)

  if @MntPLBegDate > @NowT return @MntPLBegDate
  if @PeriodUnit='d'
  begin
    set @Delta = (datediff(dd,@MntPLBegDate,@NowD)/@PeriodValue)*@PeriodValue
    set @D = dateadd(dd,@Delta,@MntPLBegDate)
    if cast(@D as date) < @NowD
    begin
      set @D=dateadd(dd,@PeriodValue,@D)
    end
  end else
  if @PeriodUnit='w'
  begin
    set @Delta = (datediff(ww,@MntPLBegDate,@NowD)/@PeriodValue)*@PeriodValue
    set @D = dateadd(ww,@Delta,@MntPLBegDate)
    if cast(@D as date) < @NowD
    begin
      set @D=dateadd(ww,@PeriodValue,@D)
    end
  end else
  if @PeriodUnit='m'
  begin
    set @Delta = (datediff(mm,@MntPLBegDate,@NowD)/@PeriodValue)*@PeriodValue
    set @D = dateadd(mm,@Delta,@MntPLBegDate)
    if cast(@D as date) < @NowD
    begin
      set @D=dateadd(mm,@PeriodValue,@D)
    end
  end else
  if @PeriodUnit='y'
  begin
    set @Delta = (datediff(yy,@MntPLBegDate,@NowD)/@PeriodValue)*@PeriodValue
    set @D = dateadd(yy,@Delta,@MntPLBegDate)
    if cast(@D as date) < @NowD
    begin
      set @D=dateadd(yy,@PeriodValue,@D)
    end
  end else
  if @PeriodUnit='c'
  begin
    -- Not supported for specified maintenance plan.
    return null
  end

  if @D is not null
  begin
    -- Updates time fraction.
    -- "@MntBegTimeB" is used for compatibility with previous versions.
    if @UseTimeFractionFromB=1
      set @D = cast(cast(@D as date) as datetime) + @MntBegTimeB else
      set @D = cast(cast(@D as date) as datetime) + @MntBegTimeA

    -- Reapply date if it less or equals to "@Now".
    -- It useful after time fraction fix.
    if @D < @NowD
    begin
      if @PeriodUnit='d' set @D=dateadd(dd,1,@D) else
      if @PeriodUnit='w' set @D=dateadd(ww,1,@D) else
      if @PeriodUnit='m' set @D=dateadd(mm,1,@D) else
      if @PeriodUnit='y' set @D=dateadd(yy,1,@D)
    end else
    begin
      if cast(@D as date) = @NowD
      begin
        if cast(@MntEMLstDate as date) = @NowD
        begin
          if @PeriodUnit='d' set @D=dateadd(dd,@PeriodValue,@D) else
          if @PeriodUnit='w' set @D=dateadd(ww,@PeriodValue,@D) else
          if @PeriodUnit='m' set @D=dateadd(mm,@PeriodValue,@D) else
          if @PeriodUnit='y' set @D=dateadd(yy,@PeriodValue,@D)
        end else
        if cast(@MntPLLstDate as date) = @NowD
        begin
          if @PeriodUnit='d' set @D=dateadd(dd,@PeriodValue,@D) else
          if @PeriodUnit='w' set @D=dateadd(ww,@PeriodValue,@D) else
          if @PeriodUnit='m' set @D=dateadd(mm,@PeriodValue,@D) else
          if @PeriodUnit='y' set @D=dateadd(yy,@PeriodValue,@D)
        end
      end
    end
    if @MntShiftHMode > 0 set @D = [dbo].[MNT_NEXT_SHIFT_HOLIDAY](@D,@MntShiftHMode)
  end

  return @D
end