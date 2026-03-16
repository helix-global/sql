-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-02-23
-- Description: Calculates proposed value for [NEXTDATE] for maintenance plan or linked equipment.
-- =============================================
-- KB5300:2025-05-13: Refactoring. Added processing for "10 Years".
-- KB4896:2024-08-01: Fixed date calculation for mode {2}.
-- KB4866:2024-06-27: Fixed date calculation for mode {1,2} where the reference date will be the date of any of the completed operations in the plan.
-- KB4859:2024-06-26: The date calculation is made the same for different periods(dd,ww,mm,yy) with no default correction. The upward correction is performed if the calculated value occurs on today's date and the related operation is also performed today.
-- KB4842:2024-06-10: Fixed date modification for (ww,mm,yy).
-- KB4839:2024-06-10: Fixed date comparision issue (separated conditions).
-- KB4838:2024-06-10: Fixed date comparision issue.
-- KB4818:2024-06-03: For [SPERIOD] and [WORKCYCLES] mode should be used minimum date from [SPERIOD] and [WORKCYCLES].
-- KB4645:2024-03-05: Additional calculations based on [WORKCYCLES] field.
--       :2024-03-19: Fixed two operation based algo implementation.
-- KB4452:2024-02-23: Initial update.
CREATE function [dbo].[MNT_NEXT_SNOOZE4](@MntID int,@MntEqID int,@MntEQLstDateOverride datetime)
returns datetime as
begin
  declare @D datetime = null
  declare @MntPeriodType int = 0
  declare @MntBegTimeA datetime
  declare @MntBegTimeB datetime
  declare @MntPLBegDate datetime
  declare @MntPLLstDate datetime
  declare @MntEQLstDate datetime
  declare @MntEMLstDate datetime
  declare @Delta int = 0
  declare @MntShiftHMode int = 0
  declare @MntCombinedPlanID int = 0
  declare @EqID int = 0
  declare @MntNDShiftMode int = 0
  declare @MntState int = 1
  declare @MntPLWorkCycles int = 0
  declare @MntEQWorkCycles int = 0
  declare @MntPLCrMode int = 0

  declare @AVG_CD float
  declare @WC_MP int,@WC_SP int,@WC_T int

  if (@MntID is null) and (@MntEqID is not null)
  begin
    -- Initialising data from [MNT_PLAN_EQ]
    select
       @MntPeriodType=[p].[SPERIOD]
      ,@MntPLBegDate=[p].[DBEG]
      ,@MntBegTimeA=cast([p].[DBEG] as time)
      ,@MntPLLstDate=[p].[LASTDATE]
      ,@MntEQLstDate=[dbo].[MNT_PLAN_EQ_LASTDATE]([e].[ID])
      ,@MntNDShiftMode=[dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE]([p].[ID])
      ,@MntShiftHMode = isnull([p].[SHIFTHMODE],0)
      ,@MntCombinedPlanID=isnull([p].[COMB_PLANID],0)
      ,@EqID=isnull([e].[EQID],0)
      ,@MntID=[p].[ID]
      ,@MntState=[dbo].[MNT_EQ_EXEC_STATE_CHECK]([q].[S_S],[p].[EXEC_EQ_STATES])
      ,@MntPLWorkCycles=isnull([p].[WORKCYCLES],0)
    from [dbo].[MNT_PLAN_EQ] [e] with(nolock)
      left join [dbo].[EQ_EQUIPMENT] [q] with(nolock) on [q].[ID]=[e].[EQID]
      left join [dbo].[MNT_PLAN]     [p] with(nolock) on [p].[ID]=[e].[VNESHID]
    where [e].[ID]=@MntEqID
  end else
  if (@MntID is not null)
  begin
    -- Initialising data from [MNT_PLAN].
    select
       @MntPeriodType=[p].[SPERIOD]
      ,@MntPLBegDate=[p].[DBEG]
      ,@MntBegTimeA=cast([p].[DBEG] as time)
      ,@MntPLLstDate=[p].[LASTDATE]
      ,@MntNDShiftMode=[dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE]([p].[ID])
      ,@MntShiftHMode = isnull([p].[SHIFTHMODE],0)
      ,@MntCombinedPlanID=isnull([p].[COMB_PLANID],0)
      ,@MntPLWorkCycles=isnull([p].[WORKCYCLES],0)
      ,@MntPLCrMode=isnull([p].[CRMODE],0)
    from [dbo].[MNT_PLAN] [p] with(nolock)
    where [p].[ID]=@MntID

    if @MntPLCrMode=2
    begin
      set @MntEMLstDate = null
      select
        @MntEMLstDate=max([p].[NEXTDATE])
      from [dbo].[MNT_PLAN_EMPLOYEE] [p] with(nolock)
      where [p].[MNT_PLAN_ID]=@MntID

      if @MntEMLstDate is not null set @MntPLLstDate=@MntEMLstDate
    end
    if @MntEMLstDate is null
    begin
      select
        @MntPLLstDate=max([o].[COMPLETED_DT])
      from [dbo].[MNT_PLAN] [p] with(nolock)
        inner join [dbo].[PR_OPERATION] [o] with(nolock) on [o].[MNT_PLANID]=[p].[ID]
      where [p].[ID]=@MntID
    end
  end

  if @MntID is null return null
  if @MntPeriodType = 0 return null
  if @MntState=0 return null

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

  if @MntEqID is not null
  begin
    --KB3982
    if @MntCombinedPlanID>0 and @EqID>0
    begin
      declare @MntCombinedEQLastDate datetime = null
      select top 1
        @MntCombinedEQLastDate=[dbo].[MNT_PLAN_EQ_LASTDATE]([e].[ID])
      from [dbo].[MNT_PLAN_EQ] [e] with(nolock)
      where [e].[EQID]=@EqID
        and [e].[VNESHID]=@MntCombinedPlanID

      if @MntCombinedEQLastDate>@MntEQLstDate set @MntEQLstDate=@MntCombinedEQLastDate
    end
  end

  declare @NowT datetime = getdate()

  if @MntNDShiftMode=1     set @MntPLBegDate=isnull(@MntPLLstDate,@MntPLBegDate)
  if @MntNDShiftMode=2
  begin
    set @MntEQLstDate=coalesce(@MntEQLstDateOverride,@MntEQLstDate)
    set @MntPLBegDate=coalesce(@MntEQLstDate,@MntPLBegDate)
    set @UseTimeFractionFromB = 0

    -- Sets "@Now" as date from past for specified equipment if it associated
    -- with completed operation.
    if (@MntEqID is not null) and (@MntEQLstDate is not null)
    begin
      set @NowT = @MntEQLstDate
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
    -- KB4645
    set @D = null
    set @NowD = cast(getdate() as date)
    if (@MntPLWorkCycles > 0) and (@MntEqID is not null)
    begin
      declare @TraceStatus int

      -- Fetching last two completed operations.
      declare @MntOperT table([OPERID] int,[DD] date)
      insert into @MntOperT
        select top 2
           [o].[ID]
          ,cast([o].[COMPLETED_DT] as date)
        from [dbo].[PR_OPERATION] [o] with(nolock)
        where [o].[MNT_PLAN_EQROW_ID]=@MntEqID
          and [o].[COMPLETED_DT] is not null
        order by [o].[COMPLETED_DT] desc

      declare @MntOper1DT date
      declare @MntOper2DT date
      declare @MntOperC int = 0
      declare @MntOperD date

      declare [c] cursor local for select [o].[DD] from @MntOperT [o]
      open [c]
      while (1=1)
      begin
        fetch next from [c] into @MntOperD
        if @@FETCH_STATUS<>0 break
        set @MntOperC=@MntOperC+1
        if  @MntOperC=1
        begin
          set @MntOper1DT=@MntOperD
        end else
        begin
          set @MntOper2DT=@MntOperD
        end
      end
      close [c]
      deallocate [c]

      set @Delta = null
      if @MntOperC = 2
      begin
        set @Delta = abs(datediff(dd,@MntOper1DT,@MntOper2DT))
        set @MntEQWorkCycles = [dbo].[EQ_WORKCYCLES](@EqID,dateadd(dd,-@Delta,@NowD),@NowD,0)
      end else
      if @MntOperC = 1
      begin
        set @Delta = abs(datediff(dd,@MntOper1DT,@MntPLBegDate))
        set @MntEQWorkCycles = [dbo].[EQ_WORKCYCLES](@EqID,dateadd(dd,-@Delta,@NowD),@NowD,0)
      end else
      begin
        set @Delta = abs(datediff(dd,@MntPLBegDate,@NowD))
        set @MntEQWorkCycles = [dbo].[EQ_WORKCYCLES](@EqID,dateadd(dd,-@Delta,@NowD),@NowD,0)
      end

      set @Delta = isnull(@Delta,0)
      if @Delta > 0
      begin
        set @WC_MP = [dbo].[EQ_WORKCYCLES](@EqID,@MntEQLstDate,@NowD,0)
        set @WC_SP = @MntEQWorkCycles

        set @AVG_CD = cast(@WC_SP as float)/@Delta
        if @AVG_CD > 0
        begin
          set @D = dateadd(dd,(@MntPLWorkCycles-@WC_MP)/@AVG_CD,@NowD)
        end
      end

      /*set @TraceStatus=[TraceSQL].[dbo].[STraceDOC]([dbo].[DEF_USERID](),1,'[dbo].[MNT_NEXT_SNOOZE4]',1000172,@MntID,
        (select
           isnull(@Delta,0) [@Delta]
          ,isnull(@MntEQWorkCycles,0) [@MntEQWorkCycles]
          ,isnull(@MntOperC,0)        [@MntOperT.Count]
          ,isnull(format(@MntOper1DT,'yyyy-MM-dd'),'null') [@MntOperT.Oper1DT]
          ,isnull(format(@MntOper2DT,'yyyy-MM-dd'),'null') [@MntOperT.Oper2DT]
          ,(select [o].[OPERID],format([o].[DD],'yyyy-MM-dd') [DD] from @MntOperT [o] for json path) [@MntOperT.{Self}]
        for json path))
        */
    end
  end

  -- KB4645
  -- Calculations based on [SPERIOD] and [WORKCYCLES]
  if (@PeriodUnit<>'c') and (@MntPLWorkCycles > 0) and (@MntEqID is not null)
  begin
    set @NowD = cast(getdate() as date)
    set @MntEQLstDate = isnull(@MntEQLstDate,@MntPLBegDate)
    set @WC_SP = [dbo].[EQ_WORKCYCLES](@EqID,dateadd(dd,-@PeriodDays,@NowD),@NowD,0)
    set @WC_MP = [dbo].[EQ_WORKCYCLES](@EqID,@MntEQLstDate,@NowD,0)
    set @WC_T  = @MntPLWorkCycles
    if @PeriodDays > 0
    begin
      set @AVG_CD = cast(@WC_SP as float)/@PeriodDays
      if @AVG_CD > 0
      begin
        declare @Dother datetime = dateadd(dd,(@WC_T-@WC_MP)/@AVG_CD,@NowD);
        if @D is not null
          --KB4818
          set @D=[dbo].[COM_MIN_DATE](@D,@Dother)
        else
          set @D = @Dother
      end
    end
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
        if cast(@MntEQLstDate as date) = @NowD
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