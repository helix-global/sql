--#AZURE06081:2025-11-25: Added call tracing.
--KB5594:2025-08-21: Changed default urgency for new operations to Default (1), added block which increments urgency based on maintenance plan's HP_DAY, HP_HOUR, HP_MINUTE.
--KB5072:2024-01-15: Commented out use of [dbo].[MNT_EQ_CHECK_PREVIOUSCOMPLETED].
--KB5071:2024-12-02: Fixed creating duplicated records for mode {3,4}.
--KB4896:2024-08-02: Removed operation logging.
--KB4896:2024-08-01: Made separation of implementations for modes 1 and 2
--KB4896:2024-07-23: Added optional parameter.
--KB4867:2024-06-28: Fixed a problem with mode {1,2} operations multiplication.
--KB4818:2024-06-03: Added invoke of [dbo].[MNT_PLAN_EQ_RECALCULATE_NEXT_DATE] for specifed maintenance plan if global [MntPlanEnableBatchRecalculateNextDate] parameter is on.
--KB4761:2024-04-20: Fixed a performance issue due checking the operations for prioritize.
--KB4740:2024-04-16: Updated operation prioritization.
--KB4672:2024-03-18: Commented tracing block. Updated document creation logging. Incompatible with version prior 13.0.
--KB4668:2024-03-12: Eliminates the creation of repeated operations in the "pending" status for {One Operation,Each Employee In Operation Group Get Operation}
--KB4452:2024-02-14: Derived from [dbo].[MNT_CHECKANDCREATE4]. It uses [dbo].[MNT_NEXT_SNOOZE4] and [dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE].
--                   Logging operation creation events. Refactoring.
--KB4641:2024-02-28: Creates operation for {One Operation,Each Employee In Operation Group Get Operation} under by @UserID.
CREATE procedure [dbo].[MNT_CHECKANDCREATE4] (@PlanID int,@UserID int,@Options nvarchar(max)=null,@ScopeGroup nvarchar(max) = null)
as
begin
  set nocount on
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[MNT_CHECKANDCREATE4]'   [@ScopeName]
      ,(select
         @PlanID  [PlanID]
        ,@UserID  [UserID]
        ,@Options [Options]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)

  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[MNT_CHECKANDCREATE4]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    declare @Now datetime = GETDATE()
    declare @Message nvarchar(max)
    declare @NewOperationIdentifiers table ([OPERID] int,[GID] uniqueidentifier,[CRMODE] int)
    declare @NewOperations table (OPERTYPE int,USERID int,MNT_PLANID int,MNTPLAN_S_CR int,MNT_HIGHPR datetime,TODOTEXT nvarchar(max),EQID int,[CRMODE] int,[GID] uniqueidentifier)
    declare @NeedUpdate table ([MNT_PLAN_ID] int not null, [NEXTDATE_SHIFT_MODE] int,index [IX-1] ([MNT_PLAN_ID]))
    declare @NewOperationID int
    declare @NeedUpdateCount int
    declare @CountA int = 0
    declare @CountB int = 0
    declare @Trace int = 0
    declare @IgnoreSnoozeDate int = 0
    declare @OptionsT table ([OPTION] nvarchar(max))
    insert into @OptionsT select [ITEM] from [dbo].[COM_STR2TABLE_STR](@Options)

    if exists(select * from @OptionsT where [OPTION] like 'Trace')              set @Trace = 1
    if exists(select * from @OptionsT where [OPTION] like 'IgnoreSnoozeDate')   set @IgnoreSnoozeDate = 1

    --{TRACE}
    /*if @Trace=1
    begin
      insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
          values (getdate(),1,'trace:{[dbo].[MNT_CHECKANDCREATE4]}',
              @UserID,-1,1000172,@PlanID,(
                select
                   @PlanID       "[MNT_CHECKANDCREATE4].@PlanID"
                  ,'Entry point' "[MNT_CHECKANDCREATE4].STEP"
                  ,'exec [dbo].[MNT_CHECKANDCREATE4]'+
                      ' @PlanID='    + isnull(cast(@PlanID as varchar(max)),'null') +
                      ',@UserID='    + isnull(cast(@UserID as varchar(max)),'null') "[MNT_CHECKANDCREATE4].SQL"
                for json path))
    end*/

    -- Updates [MNT_PLAN] only for {One Operation,Each Employee In Operation Group Get Operation}
    print N'Updating [MNT_PLAN] only for {One Operation,Each Employee In Operation Group Get Operation}...'
    update [dbo].[MNT_PLAN]
      set [NEXTDATE] = [dbo].[MNT_NEXT_SNOOZE4]([ID],null,null)
    where [NEXTDATE] is null
      and [S_S] = 1
      and [CRMODE] in (1,2)
      and ([ID] = @PlanID or @PlanID is null)

    --#region One Operation
    print N'Checking for {One Operation}...'
    insert into @NeedUpdate ([MNT_PLAN_ID],[NEXTDATE_SHIFT_MODE])
      select distinct [a].[ID],[dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE]([a].[ID])
      from [dbo].[MNT_PLAN] [a] with(nolock)
      where ([dbo].[MNT_NEXT_SNOOZE4]([a].[ID],null,null) <= @Now --KB4867
             or @IgnoreSnoozeDate=1)
        and [a].[S_S] = 1
        and [a].[CRMODE] in (1)
        and ([a].[ID] = @PlanID or @PlanID is null)

    if exists(select * from @NeedUpdate)
    begin
      select @NeedUpdateCount=count(*) from @NeedUpdate
      set @Message = N'Found plans for {One Operation}:' + cast(@NeedUpdateCount as nvarchar(max))
      print @Message
      --set @Message = @Message + N':{'+(select [dbo].[fn_str_join]([a].[MNT_PLAN_ID],',','Sorted') from @NeedUpdate [a]) +N'}'
      --insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
      --    values (getdate(),1,'trace:{[dbo].[MNT_CHECKANDCREATE4]}',
      --        @UserID,-1,1000172,@PlanID,@Message)

      /* Mode: One Operation */
      insert into @NewOperations(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT,[CRMODE],[GID])
        select distinct A.OPERID,null,A.ID,A.S_CR,dbo.MNT_HIGHPRDATETIME(@Now,A.HP_DAY,A.HP_HOUR,A.HP_MINUTE),
          cast(A.TODO as nvarchar(max)),A.CRMODE,newid()
        from MNT_PLAN A with(nolock)
        where A.ID in (select G.[MNT_PLAN_ID] from @NeedUpdate G)
          and A.CRMODE = 1
          and not exists (select * from [dbo].[PR_OPERATION] [O] with(nolock)
                          where [O].[MNT_PLANID]=[A].[ID]
                            and [O].[OPERTYPEID]=[A].[OPERID]
                            and [O].[S_S] in (
                                1000032,
                                1000031, --KB4867
                                1000033  --KB4867
                          ))

      insert into PR_OPERATION (GID,S_S,OPERTYPEID,S_CDT,S_CR,USERINPROGRESS,TODOTEXT,MNT_PLANID,HIGHPRDATE,URGENCY,EQID)
      output inserted.[ID],inserted.[GID],1 into @NewOperationIdentifiers
        select distinct
           [a].[GID]
          ,1000032
          ,[a].OPERTYPE
          ,@Now
          ,@UserID
          ,[a].USERID
          ,[a].TODOTEXT
          ,[a].MNT_PLANID
          ,[a].MNT_HIGHPR
          ,1 -- Default (enum pr_order_urgency)
          ,[a].EQID
        from @NewOperations [a]

      update MNT_PLAN
        set LASTDATE = @Now
      where ID in (select B.[MNT_PLAN_ID] from @NeedUpdate B)

      update MNT_PLAN 
        set NEXTDATE = dbo.MNT_NEXT_SNOOZE4(ID, null,null)
      where ID in (select B.[MNT_PLAN_ID] from @NeedUpdate B) 

      /*KB614*/
      update MNT_PLAN 
        set NEXTDATE = null
      where ID in (select B.[MNT_PLAN_ID] from @NeedUpdate B where B.[NEXTDATE_SHIFT_MODE] = 2)
    end
    --#endregion
    --#region Each Employee In Operation Group Get Operation
    delete from @NeedUpdate
    insert into @NeedUpdate ([MNT_PLAN_ID],[NEXTDATE_SHIFT_MODE])
      select distinct [a].[ID],[dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE]([a].[ID])
      from [dbo].[MNT_PLAN] [a] with(nolock)
      where [a].[S_S] = 1
        and [a].[CRMODE] in (2)
        and ([a].[ID] = @PlanID or @PlanID is null)
        and (exists(select *
                    from [dbo].[MNT_PLAN_EMPLOYEE] [b] with(nolock)
                    where [b].[MNT_PLAN_ID]=[a].[ID]
                      and [b].[NEXTDATE]<=@Now) or @IgnoreSnoozeDate=1)

    if exists(select * from @NeedUpdate)
    begin
      print N'Found plans for {Each Employee In Operation Group Get Operation}'

      /* Mode: Each Employee In Operation Group Get Operation */
      delete from @NewOperations
      insert into @NewOperations(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT,[CRMODE],[GID])
        select A.OPERID,[u].ID,A.ID,A.S_CR,dbo.MNT_HIGHPRDATETIME(@Now,A.HP_DAY,A.HP_HOUR,A.HP_MINUTE),A.TODO,A.CRMODE,newid()
        from MNT_PLAN A with(nolock)
          inner join [dbo].[MNT_PLAN_EMPLOYEE] [m] with(nolock) on [m].[MNT_PLAN_ID]=[A].[ID]
          inner join [dbo].[DEF_USERS]         [u] with(nolock) on [u].[EMPLOYEEID]=[m].[EMPLID]
         where A.ID in (select G.[MNT_PLAN_ID] from @NeedUpdate G)
           and A.CRMODE = 2
           and [m].[NEXTDATE] <= @Now
           and not exists (select * from [dbo].[PR_OPERATION] [O] with(nolock)
                           where [O].[MNT_PLANID]=[A].[ID]
                             and [O].[OPERTYPEID]=[A].[OPERID]
                             and [O].[USERINPROGRESS]=[u].[ID]
                             and [O].[S_S] in (
                                1000032,
                                1000031, --KB4867
                                1000033  --KB4867
                          ))

      insert into PR_OPERATION (GID,S_S,OPERTYPEID,S_CDT,S_CR,USERINPROGRESS,TODOTEXT,MNT_PLANID,HIGHPRDATE,URGENCY,EQID)
      output inserted.[ID],inserted.[GID],2 into @NewOperationIdentifiers
        select
           [a].[GID]
          ,1000032
          ,[a].OPERTYPE
          ,@Now
          ,@UserID
          ,[a].USERID
          ,[a].TODOTEXT
          ,[a].MNT_PLANID
          ,[a].MNT_HIGHPR
          ,1 -- Default (enum pr_order_urgency)
          ,[a].EQID
        from @NewOperations [a]

      update MNT_PLAN
        set LASTDATE = @Now
      where ID in (select B.[MNT_PLAN_ID] from @NeedUpdate B)

      update MNT_PLAN 
        set NEXTDATE = dbo.MNT_NEXT_SNOOZE4(ID, null,null)
      where ID in (select B.[MNT_PLAN_ID] from @NeedUpdate B) 

      /*KB614*/
      update MNT_PLAN 
        set NEXTDATE = null
      where ID in (select B.[MNT_PLAN_ID] from @NeedUpdate B where B.[NEXTDATE_SHIFT_MODE] = 2)
    end
    --#endregion
    --#region By Equipment,By Equipment (Assign Operation To Responsible Employee)
    print N'Checking for {By Equipment,By Equipment (Assign Operation To Responsible Employee)}...'
    declare @NeedUpdateEq table ([MNT_PLAN_EQ_ID] int not null,unique clustered ([MNT_PLAN_EQ_ID]))

    /*-- Fills [NEXTDATE] with proposed value if it empty
    -- only for {By Equipment,By Equipment (Assign Operation To Responsible Employee)}
    update [e]
      set [e].[NEXTDATE] = [dbo].[MNT_NEXT_SNOOZE4](null,[e].[ID],@Now)
    output inserted.ID into @NeedUpdateEq
    from [dbo].[MNT_PLAN_EQ] [e]
      inner join [dbo].[MNT_PLAN] [p] on [p].[ID]=[e].[VNESHID]
    where ([p].[S_S]=1)
      and ([p].[CRMODE] in (3,4))
      and ([p].[ID]=@PlanID or @PlanID is null)
      and ([e].[NEXTDATE] is not null)
      and ([dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE]([p].[ID])<>2) --KB1221
      */

    -- Gets [MNT_PLAN_EQ] records for {By Equipment,By Equipment (Assign Operation To Responsible Employee)}
    -- when [NEXTDATE] is less or equals to TODAY.
    merge into @NeedUpdateEq [a]
    using
      (
      select [e].[ID]
      from [dbo].[MNT_PLAN_EQ] [e] with(nolock)
        left join [dbo].[MNT_PLAN] [p] with(nolock) on [p].[ID] = [e].[VNESHID]
      where [e].[NEXTDATE] < @Now
        and [p].[S_S] = 1
        and [p].[CRMODE] in (3,4)
        and ([p].[ID] = @PlanID or @PlanID is null)
        ) [b] on [a].[MNT_PLAN_EQ_ID]=[b].[ID]
    when not matched then
      insert ([MNT_PLAN_EQ_ID]) values ([b].[ID]);

    merge into @NeedUpdateEq [a]
    using
      (
      select [e].[ID]
      from [dbo].[MNT_PLAN_EQ] [e] with(nolock)
        left join [dbo].[MNT_PLAN] [p] with(nolock) on [p].[ID] = [e].[VNESHID]
      where [p].[SPERIOD] = 100000  /*by work cycle*/
        and [p].[S_S] = 1
        and [p].[CRMODE] in (3,4)
        and ([p].[ID] = @PlanID or @PlanID is null)
        and [e].[WORKCYCLES] >= [p].[WORKCYCLES]
        and not exists (select [o].[ID]
                        from [dbo].[PR_OPERATION] [o] with(nolock)
                        where [o].[MNT_PLANID] = [p].[ID]
                          and [o].[MNT_PLAN_EQROW_ID] = [e].[ID]
                          and [o].[COMPLETED_DT] is null
                          and [o].[S_S] not in (1000023)/*canceled*/)
        ) [b] on [a].[MNT_PLAN_EQ_ID]=[b].[ID]
    when not matched then
      insert ([MNT_PLAN_EQ_ID]) values ([b].[ID]);

    declare @AffectedRecords table([ID] int)
    if exists(select [MNT_PLAN_EQ_ID] from @NeedUpdateEq)
    begin
      declare @NewOperationsEq table ([OPERTYPE] int,[USERID] int,[MNT_PLANID] int,[MNTPLAN_S_CR] int,[MNT_HIGHPR] datetime,[TODOTEXT] ntext,[EQID] int,[MNT_PLAN_EQROW_ID] int,[CRMODE] int,[GID] uniqueidentifier)
      set @CountA = 0
      set @CountB = 0

      --#region Mode: By Equipment
      insert into @NewOperationsEq([OPERTYPE],[USERID],[MNT_PLANID],[MNTPLAN_S_CR],[MNT_HIGHPR],[TODOTEXT],[EQID],[MNT_PLAN_EQROW_ID],[CRMODE],[GID])
        select [b].[OPERID],null,[b].[ID],[b].[S_CR],[dbo].[MNT_HIGHPRDATETIME](@Now,[b].[HP_DAY],[b].[HP_HOUR],[b].[HP_MINUTE]),[b].[TODO],[c].[ID],[a].[ID],[b].[CRMODE],newid()
        from [dbo].[MNT_PLAN_EQ] [a] with(nolock)
          left join [dbo].[MNT_PLAN]     [b] with(nolock) on [b].[ID]=[a].[VNESHID]
          left join [dbo].[EQ_EQUIPMENT] [c] with(nolock) on [c].[ID]=[a].[EQID]
         where [a].[ID] in (select [G].[MNT_PLAN_EQ_ID] from @NeedUpdateEq [G])
           and [b].[CRMODE] = 3
           /*and C.S_S IN( 1000173, 1000174, 2130044) *//*in use, reserve, in calibration*/
           and [dbo].[MNT_EQ_EXEC_STATE_CHECK]([c].[S_S],[b].[EXEC_EQ_STATES]) = 1 /*KB3303*/
           --KB5072: and [dbo].[MNT_EQ_CHECK_PREVIOUSCOMPLETED](null,[c].[ID],[b].[ID]) = 1  /*KB3488*/
           and not exists (select *
                           from [dbo].[PR_OPERATION] [o] with(nolock)
                           where [o].[MNT_PLANID]=[b].[ID]
                             and [o].[MNT_PLAN_EQROW_ID]=[a].[ID]
                             and [o].[OPERTYPEID]=[b].[OPERID]
                             and [o].[S_S] in (
                               1000032,
                               1000031,
                               1000033
                          ))
      select @CountA=count(*) from @NewOperationsEq
      if @CountA > 0
      begin
        print N'  By Equipment: ' + format(@CountA,N'D')
      end
      --#endregion
      --#region Mode: By Equipment (Assign Operation To Responsible Employee) */
      insert into @NewOperationsEq([OPERTYPE],[USERID],[MNT_PLANID],[MNTPLAN_S_CR],[MNT_HIGHPR],[TODOTEXT],[EQID],[MNT_PLAN_EQROW_ID],[CRMODE],[GID])
        select [b].[OPERID],[u].[ID],[b].[ID],[b].[S_CR],[dbo].[MNT_HIGHPRDATETIME](@Now,[b].[HP_DAY],[b].[HP_HOUR],[b].[HP_MINUTE]),[b].[TODO],[c].[ID],[a].[ID],[b].[CRMODE],newid()
        from [dbo].[MNT_PLAN_EQ] [a] with(nolock)
          left join [dbo].[MNT_PLAN]     [b] with(nolock) on [b].[ID]=[a].[VNESHID]
          left join [dbo].[EQ_EQUIPMENT] [c] with(nolock) on [c].[ID]=[a].[EQID]
          left join [dbo].[DEF_USERS]    [u] with(nolock) on [u].[EMPLOYEEID]=[c].[RESP_EMPLID]
         where [a].[ID] in (select [G].[MNT_PLAN_EQ_ID] from @NeedUpdateEq [G])
           and [b].[CRMODE] = 4
           /*and C.S_S IN( 1000173, 1000174, 2130044)*/ /*in use, reserve, in calibration*/
           and [dbo].[MNT_EQ_EXEC_STATE_CHECK]([c].[S_S],[b].[EXEC_EQ_STATES]) = 1 /*KB3303*/
           --KB5072: and [dbo].[MNT_EQ_CHECK_PREVIOUSCOMPLETED](null,[c].[ID],[b].[ID]) = 1  /*KB3488*/
           and not exists (select *
                           from [dbo].[PR_OPERATION] [o] with(nolock)
                           where [o].[MNT_PLANID]=[b].[ID]
                             and [o].[MNT_PLAN_EQROW_ID]=[a].[ID]
                             and [o].[OPERTYPEID]=[b].[OPERID]
                             and [o].[S_S] in (
                               1000032,
                               1000031,
                               1000033
                          ))
      select @CountB=count(*) from @NewOperationsEq
      if @CountB-@CountA > 0
      begin
        print N'  By Equipment (Assign Operation To Responsible Employee): ' + format(@CountB-@CountA,N'D')
      end
      --#endregion

      insert into [PR_OPERATION] ([GID],[S_S],[OPERTYPEID],[S_CDT],[S_CR],[USERINPROGRESS],[TODOTEXT],[MNT_PLANID],[HIGHPRDATE],[URGENCY],[EQID],[MNT_PLAN_EQROW_ID])
      output inserted.[ID],inserted.[GID],null into @NewOperationIdentifiers
        select
           [a].[GID]
          ,1000032
          ,[a].[OPERTYPE]
          ,@Now
          ,@UserID
          ,[a].[USERID]
          ,[a].[TODOTEXT]
          ,[a].[MNT_PLANID]
          ,[a].[MNT_HIGHPR]
          ,1 -- Default (enum pr_order_urgency)
          ,[a].[EQID]
          ,[a].[MNT_PLAN_EQROW_ID]
        from @NewOperationsEq [a]

      update [a] set
        [a].[CRMODE]=[b].[CRMODE]
      from @NewOperationIdentifiers [a]
        inner join @NewOperationsEq [b] on [b].[GID]=[a].[GID]

      /*
      MNT_PLAN_EQ.LEMODE
      0 - none
      1 - Put specified linked equipment into operation
      2 - Put all linked equipment from affected equipment into operation
      */

      insert into [dbo].[PR_OPERATION_EQUIPMENT] ([GID],[S_CR],[S_CDT],[OPERID],[EQID],[WASAUTOCREATED])
        select newid(),@UserID,@Now,[B].[ID],[D].[EQID],1
        from @NewOperationIdentifiers A
          left join [dbo].[PR_OPERATION]          [B] with(nolock) on [B].[ID]=[A].[OPERID]
          left join [dbo].[MNT_PLAN_EQ]           [C] with(nolock) on [C].[ID]=[B].[MNT_PLAN_EQROW_ID]
          left join [dbo].[MNT_PLAN_EQ_LINKED_EQ] [D] with(nolock) on [D].[VNESHID]=[C].[ID]
        where [C].[ID] is not null
          and [C].[LEMODE] = 1
          and [D].[EQID] is not null

      insert into [dbo].[PR_OPERATION_EQUIPMENT] ([GID],[S_CR],[S_CDT],[OPERID],[EQID],[WASAUTOCREATED])
        select newid(),@UserID,@Now,[B].[ID],[D].[LINKED_EQID],1
        from @NewOperationIdentifiers A
          left join [dbo].[PR_OPERATION]        [B] with(nolock) on [B].[ID]=[A].[OPERID]
          left join [dbo].[MNT_PLAN_EQ]         [C] with(nolock) on [C].[ID]=[B].[MNT_PLAN_EQROW_ID]
          left join [dbo].[EQ_EQUIPMENT_LINKED] [D] with(nolock) on [D].[VNESHID]=[C].[EQID]
        where [C].[ID] is not null
          and [C].[LEMODE] = 2
          and [D].[LINKED_EQID] is not null

      -- KB4452: [LASTDATE] doesn't use. Should be used calculated value by [dbo].[MNT_PLAN_EQ_LASTDATE.
      --         The following code was commented.
      /*delete from @AffectedRecords
      update [dbo].[MNT_PLAN_EQ]
        set [LASTDATE] = @Now
      output inserted.ID into @AffectedRecords
      where [ID]     in (select B.[ID] from @NeedUpdateEq B)
        and [ID] not in (select [MNT_PLAN_EQROW_ID] from @NewOperationsEq)

      -- Clear [MNT_PLAN_EQ].[LAST DATE] for equipment associated with operation.
      -- This value should be processed by operation behavior.
      update [dbo].[MNT_PLAN_EQ]
        set [LASTDATE] = null
      output inserted.ID into @AffectedRecords
      where [ID] in (select [MNT_PLAN_EQROW_ID] from @NewOperationsEq)
      */

      /*update [e]
        set [e].[NEXTDATE] = [dbo].[MNT_NEXT_SNOOZE4](null,[e].[ID],null)
      from [dbo].[MNT_PLAN_EQ] [e]
        left join [dbo].[MNT_PLAN] P on P.ID = [e].[VNESHID]
      where [e].[ID] in (select B.ID from @NeedUpdateEq B)
        and [e].[ID] in (select MNT_PLAN_EQROW_ID from @NewOperationsEq)

      -- KB0614
      update [e]
        set [NEXTDATE] = null
      from [dbo].[MNT_PLAN_EQ] [e]
        left join [dbo].[MNT_PLAN] [p] on [p].[ID] = [e].[VNESHID]
      where [e].[ID] in (select B.ID from @NeedUpdateEq B)
        and [dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE]([p].[ID]) = 2
        and [e].[ID] in (select [MNT_PLAN_EQROW_ID] from @NewOperationsEq)
      */

      update [dbo].[MNT_PLAN]
        set NEXTDATE = (select min(B.NEXTDATE) from MNT_PLAN_EQ B where B.VNESHID = MNT_PLAN.ID)
      where MNT_PLAN.ID in (select distinct F.VNESHID from MNT_PLAN_EQ F where F.ID in (select B.[MNT_PLAN_EQ_ID] from @NeedUpdateEq B))
    end
    --#endregion
    --#region Logging for created operations {KB4452}.
    if exists(select * from @NewOperationIdentifiers)
    begin
      declare [c] cursor local read_only for
        select [a].[OPERID] from @NewOperationIdentifiers [a]
      open [c]
      while 1=1
      begin
        fetch next from [c] into @NewOperationID
        if @@FETCH_STATUS<>0 break
        insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
            values (getdate(),1,'Document created.',
                @UserID,20000,1000039,@NewOperationID,(
                  select top 1
                     @NewOperationID         "ID"
                    ,[o].[S_S]               "S_S"
                    ,[o].[OPERTYPEID]        "OPERTYPEID"
                    ,[o].[S_CDT]             "S_CDT"
                    ,[o].[S_CR]              "S_CR"
                    ,[o].[USERINPROGRESS]    "USERINPROGRESS"
                    ,[o].[TODOTEXT]          "TODOTEXT"
                    ,[o].[MNT_PLANID]        "MNT_PLANID"
                    ,[o].[HIGHPRDATE]        "HIGHPRDATE"
                    ,[o].[URGENCY]           "URGENCY"
                    ,[o].[EQID]              "EQID"
                    ,[o].[MNT_PLAN_EQROW_ID] "MNT_PLAN_EQROW_ID"
                    ,[o].[GID] [GID]
                    ,'a2l:\\Link=doc.mnt_plan.'+cast([o].[MNT_PLANID] as varchar(max)) "PDB_MNT_PLAN_LINK"
                  from [dbo].[PR_OPERATION] [o] (nolock)
                  where [o].[ID]=@NewOperationID
                  for xml path))
      end
      close [c]
      deallocate [c]
    end
    --#endregion
    --#region Checking operations to determine priority.
    print N'Checking operations to determine priority...'
    declare @OperationsToPrioritize table([OPERID] int, [OLD_URGENCY] int, [NEW_URGENCY] int
      ,index [IX-1]([OPERID]))

    -- Main priority update: increment priority based on maintenance plan's [HP_DAY], [HP_HOUR], [HP_MINUTE]
    -- See also KB5504: [MP] Priority changes
    print '  Main priority change block (based on maintenance plan''s HP_DAY, HP_HOUR, HP_MINUTE)...';
    with [T] as (
      select
        op.[ID],
        op.[URGENCY],
        case
          when [dbo].[MNT_HIGHPRDATETIME](op.[S_CDT], maintPlan.[HP_DAY] * 3, maintPlan.[HP_HOUR] * 3, maintPlan.[HP_MINUTE] * 3) <= @Now then 10 /* Exceptional */
          when [dbo].[MNT_HIGHPRDATETIME](op.[S_CDT], maintPlan.[HP_DAY] * 2, maintPlan.[HP_HOUR] * 2, maintPlan.[HP_MINUTE] * 2) <= @Now then 3 /* Very High */
          when [dbo].[MNT_HIGHPRDATETIME](op.[S_CDT], maintPlan.[HP_DAY], maintPlan.[HP_HOUR], maintPlan.[HP_MINUTE]) <= @Now then 2 /* High */
          else op.[URGENCY]
        end as [NEW_URGENCY]
      from
        [dbo].[PR_OPERATION] op (nolock)
        join [dbo].[MNT_PLAN] maintPlan (nolock) on maintPlan.[ID] = op.[MNT_PLANID]
      where
        op.[S_S] in (1000032 /* Pending */, 1000033 /* Postponed */, 1000018 /* Failure */, 1000038 /* Failure processed */)
        and op.[URGENCY] < 10	/* Exceptional */
        and maintPlan.[S_S] != 1000136 /* Disabled */
        and ( isnull(maintPlan.[HP_DAY], 0) > 0 or isnull(maintPlan.[HP_HOUR], 0) > 0 or isnull(maintPlan.[HP_MINUTE], 0) > 0 )
    )
    insert into @OperationsToPrioritize ([OPERID], [OLD_URGENCY], [NEW_URGENCY])
    select [ID], [URGENCY], [NEW_URGENCY]
    from [T]
    where [URGENCY] != [NEW_URGENCY];

    print '  Main priority change block: ' + cast(@@ROWCOUNT as nvarchar(10));

    -- Compatibility block by obsolete conditions.
    print N'  Compatibility block by obsolete conditions (based on [HIGHPRDATE] field)...'
    insert into @OperationsToPrioritize ([OPERID], [OLD_URGENCY], [NEW_URGENCY])
      select [o].[ID], o.[URGENCY], 10
      from [dbo].[MNT_PLAN] [p] with(nolock)
        inner join [dbo].[PR_OPERATION] [o] with(nolock) on [o].[MNT_PLANID]=[p].[ID]
      where ([o].[S_S] in (1000032))
        and ([o].[MNT_PLANID]=@PlanID or @PlanID is null)
        and (isnull([o].[URGENCY],0)<10)
        and ([o].[HIGHPRDATE]<=@Now)
        and not exists (select 1 from @OperationsToPrioritize [ops] where ops.[OPERID] = [o].[ID])

    print N'  Compatibility block by obsolete conditions (based on [HIGHPRDATE] field): ' + cast(@@ROWCOUNT as nvarchar(10))

    -- KB4740.
    -- Based on operation creation time and maintenance plan parameters (prioritization parameters).
    declare @OperationsToPrioritizeCandidates table([OPERID] int, [HIGHPRDATETIME] datetime, [SHIFTHMODE] int, [URGENCY] int
     ,index [IX-1] ([OPERID])
     ,index [IX-2] ([SHIFTHMODE])
     ,index [IX-3] ([SHIFTHMODE],[HIGHPRDATETIME]))
    print N'  Based on operation creation time and maintenance plan parameters (prioritization parameters)...';
    with [T]
    as
      (
      select
          [o].[ID] [OPERID]
         ,[dbo].[MNT_HIGHPRDATETIME]([o].[S_CDT],[p].[HP_DAY],[p].[HP_HOUR],[p].[HP_MINUTE]) [HIGHPRDATETIME]
         ,isnull([p].[SHIFTHMODE],0) [SHIFTHMODE]
         ,[o].[URGENCY]
      from [dbo].[MNT_PLAN] [p] with(nolock)
        inner join [dbo].[PR_OPERATION] [o] with(nolock) on [o].[MNT_PLANID]=[p].[ID]
      where ([o].[S_S] in (1000032))
        and ([p].[ID]=@PlanID or (@PlanID is null))
        and (isnull([o].[URGENCY],0)<10)
        and not exists (select 1 from @OperationsToPrioritize [ops] where ops.[OPERID] = [o].[ID])
      )
    insert into @OperationsToPrioritizeCandidates
      select * from [T] where [HIGHPRDATETIME] is not null

    print N'  Operations without specifying a time offset...';
    merge @OperationsToPrioritize [a]
    using
      (
      select
         [OPERID], [URGENCY]
      from @OperationsToPrioritizeCandidates
      where [SHIFTHMODE]=0
        and [HIGHPRDATETIME]<=@Now
      ) [b] on [b].[OPERID]=[a].[OPERID]
    when not matched then
      insert ([OPERID], [OLD_URGENCY], [NEW_URGENCY]) values ([b].[OPERID], b.[URGENCY], 10);

    print N'  Operations with specifying a time offset(possible long time query)...';
    merge @OperationsToPrioritize [a]
    using
      (
      select
         [OPERID], [URGENCY]
      from @OperationsToPrioritizeCandidates
      where [SHIFTHMODE]<>0
        and ([dbo].[MNT_NEXT_SHIFT_HOLIDAY]([HIGHPRDATETIME],[SHIFTHMODE])<=@Now)
      ) [b] on [b].[OPERID]=[a].[OPERID]
    when not matched then
      insert ([OPERID], [OLD_URGENCY], [NEW_URGENCY]) values ([b].[OPERID], [b].[URGENCY], 10);

    --#endregion
    --#region Updates urgency for selected operations.
    print N'Updating urgency for selected operations...'
    update [a] set
      [a].[URGENCY] = [b].[NEW_URGENCY]
    from [dbo].[PR_OPERATION] [a]
      inner join @OperationsToPrioritize [b] on [b].[OPERID]=[a].[ID]
    where [a].[URGENCY] != [b].[NEW_URGENCY];

    -- Write URGENCY changes to log.
    insert into [dbo].[DEF_LOG] ([DD], [LEV], [CAPTION],
      [S_USERID], [EV_TYPE], [DOCOID], [DOCID],
      [EV_TEXT])
    select
      @Now, 1, 'Document''s urgency is automatically updated.',
      @UserID, 20000, 1000039, [a].[OPERID],
      (
        select top 1
           [a].[OPERID]            "ID"
          ,[a].[OLD_URGENCY]       "OLD_URGENCY"
          ,[o].[URGENCY]           "URGENCY"
          ,[o].[GID] [GID]
          ,'a2l:\\Link=doc.mnt_plan.'+cast([o].[MNT_PLANID] as varchar(max)) "PDB_MNT_PLAN_LINK"
        from [dbo].[PR_OPERATION] [o] (nolock)
        where [o].[ID]=[a].[OPERID]
        for xml path) as [EV_TEXT]
    from @OperationsToPrioritize [a]
    where [a].[OLD_URGENCY] != [a].[NEW_URGENCY];

    if exists(select *
              from [dbo].[DEF_SYSCONST] [a] with(nolock)
              where [a].[LABEL] = 'MntPlanEnableBatchRecalculateNextDate'
                and [a].[VALUEINT]=1)
    begin
      exec [dbo].[MNT_PLAN_EQ_RECALCULATE_NEXT_DATE] @MntPlanID=@PlanID
    end
    --#endregion

    -- Post-processing of operations.
    -- Including identification of the employee being trained.
    declare [c] cursor local read_only for
      select OPERID from @NewOperationIdentifiers
    open [c]
    while 1=1
    begin
        fetch next from [c] into @NewOperationID;
        if @@FETCH_STATUS<>0 break;
        exec [dbo].[COM_FILL_TRAINING_OPERATION] @NewOperationID,@ScopeGroup=@ScopeGroup
    end
    close [c]
    deallocate [c]
    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{2c4d6d31-daa8-405b-81d7-f23cd80d52a1}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[MNT_CHECKANDCREATE4]'   [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{179bfff3-47c4-49e1-baf0-14ecf6e9a2ac}}';
    throw;
  end catch
  set nocount off
end