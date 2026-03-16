
-- KB5300:2025-05-13: Refactoring.
-- KB4452:2024-02-23: Using [dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE] instead of accessing fields.
--                    Using [dbo].[MNT_NEXT_SNOOZE4] instead of [dbo].[MNT_NEXT_SNOOZE3]
--                    Setting [NEXTDATE] should be applying for "Shift Period By Initial DateTime" also.
CREATE procedure [dbo].[MNT_UPDATE_PLAN_IFNEED]
   @OperationID int,
   @UserID int
as
  set nocount on

  declare @CompletionDate datetime
  declare @MntPlanMode int
  declare @MntPlanId int
  declare @MntEqRowId int
  declare @MntSPeriod int
  declare @ShiftMode int
  declare @CombinedPlanID int /*KB3982 если указан, то в нем обнулять WORKCYCLES (если он по циклам)*/

  select
     @OperationID = [opr].[ID]
    ,@MntPlanId = [pla].[ID]
    ,@MntPlanMode = [pla].[CRMODE]
    ,@CompletionDate = [opr].[COMPLETED_DT]
    ,@MntEqRowId = [opr].[MNT_PLAN_EQROW_ID]
    ,@MntSPeriod = [pla].[SPERIOD]
    ,@ShiftMode = [dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE]([pla].[ID])
    ,@CombinedPlanID = [pla].[COMB_PLANID]
  from [dbo].[PR_OPERATION] [opr] with(nolock)
    left join [dbo].[MNT_PLAN]  [pla] with(nolock) on [pla].[ID]=[opr].[MNT_PLANID]
    left join [dbo].[PR_DEVICE] [dev] with(nolock) on [dev].[ID]=[opr].[DEVICEID]
  where [opr].[ID] = @OperationID
    and [opr].[S_S] in (1000013,1000019)
    and [opr].[MNT_PLANID] is not null
    and [pla].[S_S] = 1

  if @OperationID is null
  begin
    set nocount off
    return
  end

  if @MntSPeriod = 100000 and @MntEqRowId is not null and @MntPlanMode in (3,4)
  begin
    update [a] set
      [a].[WORKCYCLES] = 0
    from [dbo].[MNT_PLAN_EQ] [a]
    where [a].[ID] = @MntEqRowId
  end

  if @CombinedPlanID is not null and @MntEqRowId is not null /*KB3982*/
  begin
    declare @cEqItemID int

    select
      @cEqItemID = [a].[EQID]
    from [dbo].[MNT_PLAN_EQ] [a] with(nolock)
    where [a].[ID]=@MntEqRowId

    declare @cPeriod int
    declare @cRowEqID int
    declare @cMode int

    select top 1
       @cRowEqID = [a].[ID]
      ,@cPeriod = [b].[SPERIOD]
      ,@cMode = [b].[CRMODE]
    from [dbo].[MNT_PLAN_EQ] [a] with(nolock)
      left join [dbo].[MNT_PLAN] [b] with(nolock) on [b].[ID]=[a].[VNESHID]
    where [b].[ID] = @CombinedPlanID
      and [a].[EQID] = @cEqItemID

    if @cPeriod = 100000 and @cRowEqID is not null and @cMode in (3,4)
    begin
      update [a] set
        [a].[WORKCYCLES] = 0
      from [dbo].[MNT_PLAN_EQ] [a]
      where [a].[ID] = @cRowEqID
    end
  end

  if @ShiftMode in (0,2)
  begin
    if (@MntPlanMode = 1) /*One Operation*/
    begin
      update [a] set
        [a].[NEXTDATE] = [dbo].[MNT_NEXT_SNOOZE4]([a].[ID], null, @CompletionDate)
      from [dbo].[MNT_PLAN] [a]
      where [a].[NEXTDATE] is null
        and [a].[ID] = @MntPlanId
      return
    end

    if (@MntPlanMode = 2) /*Each Employee In Operation Group Get Operation*/
    begin
      -- TODO: maybe additional logic is needed
      update [a] set
        [a].[NEXTDATE] = [dbo].[MNT_NEXT_SNOOZE4]([a].[ID], null, @CompletionDate)
      from [dbo].[MNT_PLAN] [a]
      where [a].[NEXTDATE] is null
        and [a].[ID] = @MntPlanId
      return
    end

    if (@MntPlanMode = 3 and @MntEqRowId is not null) /*By Equipment*/
    begin
      update [a] set
        [a].[NEXTDATE] = [dbo].[MNT_NEXT_SNOOZE4](null,[a].[ID],@CompletionDate)
      from [dbo].[MNT_PLAN_EQ] [a]
      where [a].[ID] = @MntEqRowId

      update [a] set
        [a].[NEXTDATE] = (select min([b].[NEXTDATE])
                          from [MNT_PLAN_EQ] [b] with(nolock)
                          where [b].[VNESHID] = [a].[ID]
                            and [b].[NEXTDATE] is not null)
      from [dbo].[MNT_PLAN] [a]
      where [a].[ID] = @MntPlanId

      return
    end

    if (@MntPlanMode = 4 and @MntEqRowId is not null) /*By Equipment (Assign Operation To Responsible Employee)*/
    begin
      -- TODO: maybe additional logic is needed
      update [a] set
        [a].[NEXTDATE] = [dbo].[MNT_NEXT_SNOOZE4](null,[a].[ID],@CompletionDate)
      from [dbo].[MNT_PLAN_EQ] [a]
      where [a].[ID] = @MntEqRowId

      update [a] set
        [a].[NEXTDATE] = (select min([b].[NEXTDATE])
                          from [MNT_PLAN_EQ] [b] with(nolock)
                          where [b].[VNESHID] = [a].[ID]
                            and [b].[NEXTDATE] is not null)
      from [dbo].[MNT_PLAN] [a]
      where [a].[ID] = @MntPlanId

      return
    end
  end

  set nocount off