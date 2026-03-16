-- KB5278:2025-07-11: Refactoring.
-- KB5238:2025-01-30: Fixed error [COM_TRAINING_MAINTENANCE]<->[PR_OPERATION] association.
-- KB5221:2025-01-23: The assignment of [COM_TRAINING_MAINTENANCE]<->[PR_OPERATION] has been updated.
-- #AZURE06081:2025-11-25: Added call tracing.
CREATE PROCEDURE [dbo].[COM_FILL_TRAINING_OPERATION] (
    @operID int,@ScopeGroup nvarchar(max)=null
)
AS
BEGIN
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[COM_FILL_TRAINING_OPERATION]' [@ScopeName]
      ,(select
         @operID [OperID]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)

  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[COM_FILL_TRAINING_OPERATION]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    declare @trainingOperIDs table ([trainingOperID] int)
    declare @modelId int, @revId int, @deviceId int

    select
       @modelId=[dev].[MODELID]
      ,@revId=[dev].[REVID]
      ,@deviceId=[opr].[DEVICEID]
    from [dbo].[PR_OPERATION] [opr]
      inner join [dbo].[PR_DEVICE] [dev] on [opr].[DEVICEID]=[dev].[ID]
    where [opr].[ID]=@operID

    declare @UserID int

    select @UserID=[usr].[ID]
    from [dbo].[COM_TRAINING_OPERATIONS] [trO] with(nolock)
      left join [dbo].[COM_TRAINING] [tra] with(nolock) on [trO].[TRAININGID]=[tra].[ID]
      left join [dbo].[DEF_USERS]    [usr] with(nolock) on [tra].[EMPLOYEEID]=[usr].[EMPLOYEEID]
      left join [dbo].[PR_OPERATION] [opr] with(nolock) on [trO].[MAPOPER_ID]=[opr].[REVOPERID] and [trO].[DEVICE_ID]=[opr].[DEVICEID]
    where [opr].[ID]=@operID
      and [tra].[S_S]=4760002

    if @UserID is null
    begin
      select @UserID=[usr].[ID]
      from [dbo].[COM_TRAINING_OPERATIONS] [trO] with(nolock)
        left join [dbo].[COM_TRAINING] [tra] with(nolock) on [trO].[TRAININGID]=[tra].[ID]
        left join [dbo].[DEF_USERS]    [usr] with(nolock) on [tra].[EMPLOYEEID]=[usr].[EMPLOYEEID]
        left join [dbo].[PR_OPERATION] [opr] with(nolock) on [trO].[MAPOPER_ID]=[opr].[REVOPERID] and [trO].[DEVICE_ID] is null
        left join [dbo].[PR_DEVICE]    [dev] with(nolock) on [opr].[DEVICEID]=[dev].[ID] and [trO].[REVISIONID]=[dev].[REVID]
      where [opr].[ID]=@operID
        and [tra].[S_S]=4760002
        and not exists( select [OPERID] from [dbo].[COM_TRAINING_OPERATIONS] where [OPERID]=[opr].[ID])
    end

    if @UserID is null
    begin
      select @UserID=[usr].[ID]
      from [dbo].[COM_TRAINING_OPERATIONS] [trO] with(nolock)
        left join [dbo].[COM_TRAINING] [tra] with(nolock) on [trO].[TRAININGID]=[tra].[ID]
        left join [dbo].[DEF_USERS]    [usr] with(nolock) on [tra].[EMPLOYEEID]=[usr].[EMPLOYEEID]
        left join [dbo].[PR_OPERATION] [opr] with(nolock) on [trO].[OPERID]=[opr].[ID]
      where [opr].[ID]=@operID
        and [tra].[S_S]=4760002
    end

    if @UserID is not null
    begin
      insert into @trainingOperIDs ([trainingOperID])
        select [trO].[ID]
        from [dbo].[COM_TRAINING_OPERATIONS] [trO] with(nolock)
          inner join [dbo].[COM_TRAINING] [tra] with(nolock) on [trO].[TRAININGID]=[tra].[ID]
          inner join [dbo].[DEF_USERS]    [usr] with(nolock) on [tra].[EMPLOYEEID]=[usr].[EMPLOYEEID]
          inner join [dbo].[PR_OPERATION] [opr] with(nolock) on [trO].[MAPOPER_ID]=[opr].[REVOPERID] and [trO].[DEVICE_ID]=[opr].[DEVICEID]
        where [opr].[ID]=@operID
          and [tra].[S_S]=4760002

      insert into @trainingOperIDs ([trainingOperID])
        select min([trO].[ID])
        from [dbo].[COM_TRAINING_OPERATIONS] [trO] with(nolock)
          inner join [dbo].[COM_TRAINING] [tra] with(nolock) on [trO].[TRAININGID]=[tra].[ID]
          inner join [dbo].[DEF_USERS]    [usr] with(nolock) on [tra].[EMPLOYEEID]=[usr].[EMPLOYEEID]
          inner join [dbo].[PR_OPERATION] [opr] with(nolock) on [trO].[MAPOPER_ID]=[opr].[REVOPERID] and [trO].[DEVICE_ID] is null
          inner join [dbo].[PR_DEVICE]    [dev] on [opr].[DEVICEID]=[dev].[ID] and [trO].[REVISIONID]=[dev].[REVID]
        where [opr].[ID]=@operID
          and [tra].[S_S]=4760002
          and [trO].[OPERID] is null and isnull([tra].[AUTOINCLUDE_ITEM],0)=1
          and [usr].[ID]=@UserID
          and not exists( select [OPERID] from [dbo].[COM_TRAINING_OPERATIONS] where [OPERID]=[opr].[ID])
        group by [trO].[TRAININGID]

      update [dbo].[COM_TRAINING_OPERATIONS] set
        [OPERID]=@operID,
        [MODELID] = @modelId,
        [REVISIONID] = @revId,
        [DEVICE_ID] = @deviceId
      where [ID] in (select trainingOperID from @trainingOperIDs)

      update [dbo].[PR_OPERATION] set [USERINTRAINING]=@UserID
        where [ID]=@operID

      set @UserID = null
    end

    delete from @trainingOperIDs

    select @UserID=[usr].[ID]
    from [dbo].[COM_TRAINING_PREPARATORY] [trO] with(nolock)
      inner join [dbo].[COM_TRAINING]   [tra] with(nolock) on [trO].[TRAINING_ID]=[tra].[ID]
      inner join [dbo].[DEF_USERS]      [usr] with(nolock) on [tra].[EMPLOYEEID]=[usr].[EMPLOYEEID]
      inner join [dbo].[PR_PREPARATORY] [pre] with(nolock) on [trO].[PREPARATORY_ID]=[pre].[ID]
      inner join [dbo].[PR_OPERATION]   [opr] with(nolock) on [pre].[OPERID]=[opr].[OPERTYPEID]
    where [opr].[ID]=@operID
      and [tra].[S_S]=4760002

    if @UserID is not null
    begin
      insert into @trainingOperIDs ([trainingOperID])
        select [trO].[ID]
        from [dbo].[COM_TRAINING_PREPARATORY] [trO] with(nolock)
          inner join [dbo].[COM_TRAINING]   [tra] with(nolock) on [trO].[TRAINING_ID]=[tra].[ID]
          inner join [dbo].[DEF_USERS]      [usr] with(nolock) on [tra].[EMPLOYEEID]=[usr].[EMPLOYEEID]
          inner join [dbo].[PR_PREPARATORY] [pre] with(nolock) on [trO].[PREPARATORY_ID]=[pre].[ID]
          inner join [dbo].[PR_OPERATION]   [opr] with(nolock) on [pre].[OPERID]=[opr].[OPERTYPEID]
        where [opr].[ID]=@operID
          and [tra].[S_S]=4760002
          and [trO].[OPERID] is null

      /*   update [COM_TRAINING_PREPARATORY] set [OPERID]=@operID
            where [ID] in (select trainingOperID from @trainingOperIDs)      */

      update [dbo].[PR_OPERATION] set [USERINTRAINING]=@UserID
        where [ID]=@operID
    end

    delete from @trainingOperIDs

    declare @TrMntID int = null
    -- KB5221
    -- The first record from [COM_TRAINING_MAINTENANCE] that does not have a filled [OPERID] field and at the same time
    -- matches similar records from [PR_OPERATION] according to the criteria of operational form and maintenance plan
    -- assignment (including equipment) with the [USERINTRAINING] field not yet filled is selected.
    select top 1
       @UserID=[usr].[ID]
      ,@TrMntID=[trm].[ID]
    from [dbo].[COM_TRAINING_MAINTENANCE] [trm] with(nolock)
      inner join [dbo].[COM_TRAINING] [tra] with(nolock) on [trm].[TRAININGID]=[tra].[ID]
      inner join [dbo].[DEF_USERS]    [usr] with(nolock) on [tra].[EMPLOYEEID]=[usr].[EMPLOYEEID]
      inner join [dbo].[PR_OPERATION] [opr] with(nolock) on [trm].[OPERFORM_ID]=[opr].[OPERTYPEID]
      inner join [dbo].[MNT_PLAN_EQ]  [meq] with(nolock) on [meq].[ID]=[opr].[MNT_PLAN_EQROW_ID]
      inner join [dbo].[MNT_PLAN]     [mpl] with(nolock) on [mpl].[ID]=[opr].[MNT_PLANID]
    where [opr].[ID]=@operID
      and [tra].[S_S]=4760002
      and [mpl].[CRMODE] in (3,4)
      and [meq].[EQID]=[trm].[EQID]
      and [trm].[OPERID] is null
      and [opr].[USERINTRAINING] is null

    if @UserID is not null and @TrMntID is not null
    begin
      update [trm] set
        [trm].[OPERID]=@operID
      from [dbo].[COM_TRAINING_MAINTENANCE] [trm]
      where [trm].[ID]=@TrMntID

      update [opr] set
        [opr].[USERINTRAINING]=@UserID
      from [dbo].[PR_OPERATION] [opr]
      where [opr].[ID]=@operID
    end
    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{45a89c32-d682-4a7f-8897-ccab1b046884}}';
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[COM_FILL_TRAINING_OPERATION]'    [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{7e23b931-24d6-4e18-be18-ae7b72637e0c}}';
    throw;
  end catch
END