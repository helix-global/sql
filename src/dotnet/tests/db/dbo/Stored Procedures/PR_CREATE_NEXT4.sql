-- KB5351:2025-07-11: Refactoring. Operation creation logging.
-- #AZURE06081:2025-11-25: Added call tracing.
CREATE procedure [dbo].[PR_CREATE_NEXT4]
  @MapID int,@DoneOper int,@DoneLevel int,@NextLevel int,
  @OrdID int,@DeviceID int,@lastUserInProgress int,
  @UserID int,@parentOpID int,@TrMapN int,@InQuantity int,
  @ScopeGroup nvarchar(max) = null
as
  set nocount on
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[PR_CREATE_NEXT4]'      [@ScopeName]
      ,(select
           @MapID              [MapID]
          ,@DoneOper           [DoneOper]
          ,@DoneLevel          [DoneLevel]
          ,@NextLevel          [NextLevel]
          ,@OrdID              [OrdID]
          ,@DeviceID           [DeviceID]
          ,@lastUserInProgress [LastUserInProgress]
          ,@UserID             [UserID]
          ,@parentOpID         [ParentOpID]
          ,@TrMapN             [TrMapN]
          ,@InQuantity         [InQuantity]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)

  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[PR_CREATE_NEXT4]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    declare @now datetime
    set @now = getdate()

    declare @devFlow table ([FLOWID] int not null,[TOID] int,[CONDITION] int not null)

    insert into @devFlow ([FLOWID],[TOID],[CONDITION])
      select [ID],[OP_TO],isnull([CONDITION],0)
      from [dbo].[PR_MAP_FLOW] with(nolock)
      where [MAPID] = @MapID
        and [OP_FROM] = @DoneOper

    if @DoneOper is null
    begin
      insert into @devFlow ([FLOWID],[TOID],[CONDITION])
        select [ID],[OP_TO],isnull([CONDITION],0)
        from [dbo].[PR_MAP_FLOW] with(nolock)
        where [MAPID] = @MapID
          and [OP_FROM] is null
          and [OP_TO] is not null
    end

    delete from @devFlow
    where [CONDITION] not in (0,100)
      and [dbo].[PR_FLOW_OR_OPER_ALLOWED]([FLOWID],null,@DeviceID) = 0

    delete from @devFlow /* убрать RestWay если есть другой выход из операции */
    where [CONDITION] = 100
      and exists (select [b].[FLOWID]
                  from @devFlow [b]
                  where [b].[FLOWID] <> [@devFlow].[FLOWID])

    delete from @devFlow /* убрать если не завершены предыдущие операции, связанные обязательными связями. */
    where exists (select [mapF].[ID]
                  from [dbo].[PR_MAP_FLOW] [mapF] with(nolock)
                  where [mapF].[MAPID] = @MapID
                    and [mapF].[OP_TO] = "@devFlow".[TOID]
                    and [mapF].[OP_FROM] is not null
                    and isnull([mapF].[FLOWNOWAIT],0) = 0
                    and [dbo].[PR_FLOW_OR_OPER_ALLOWED]([mapF].[ID],null,@DeviceID) = 1 /*28.06.17 если связь по условиям - активна*/
                    and [dbo].[PR_PREVIOS_OP_DONE3](@DeviceID,@OrdID,@DoneLevel,[mapF].[OP_FROM],@parentOpID,@TrMapN) = 0)

    declare @Opers table ([REVOPERID] int not null
      ,[OPERID] int not null
      ,[CANDO] int not null
      ,[OPEREXISTS] int not null
      ,[VISMODE] int
      ,[SETUSERID] int
      ,[SKIPPED] int
      ,[OPLEVEL] int
      ,[LEVELUP] int
      ,[CONDITION] int
      ,[TC_ACTION] int
      ,[TC_MINUTE] int
      ,SCHEME_GROUP int
      ,[MANHOUR] decimal(10,4)
      ,[TODOTEXT] ntext
      ,[EMPLID] int
      ,[CREATEDBYOPERID] int
      ,[CREATEHIDDEN] int
      ,[EXISTINGOPERID] int
      ,[HIDEOTHER] int
      ,[TODOTEXT_SHOWMSG] int
      )

    insert into @Opers ([REVOPERID],[OPERID],[CANDO],[OPEREXISTS],[VISMODE],[OPLEVEL],[LEVELUP],[CONDITION],[TC_ACTION],[TC_MINUTE],[SCHEME_GROUP],[CREATEDBYOPERID],[CREATEHIDDEN],[HIDEOTHER])
      select
         [mapO].[ID]
        ,[oprF].[ID]
        ,1
        ,0
        ,isnull([oprG].[VISTYPE],0)
        ,@DoneLevel
        ,isnull([mapF].[FLOWNOWAIT],0)
        ,isnull([mapO].[CONDITION],0)
        ,[mapO].[TC_ACTION]
        ,[mapO].[TC_MINUTE]
        ,[mapO].[SCHEME_GROUP]
        ,@DoneLevel
        ,isnull([mapF].[CREATEHIDDEN],0)
        ,isnull([mapO].[HIDEOTHER],0)
      from [dbo].[PR_MAP_FLOW] [mapF] with(nolock)
        left join [dbo].[PR_MAP_OPER]      [mapO] with(nolock) on [mapO].[ID]=[mapF].[OP_TO]
        left join [dbo].[PR_OPERATIONS]    [oprF] with(nolock) on [oprF].[ID]=[mapO].[OPERID]
        left join [dbo].[PR_OPERATIONS_GR] [oprG] with(nolock) on [oprG].[ID]=[oprF].[OPERGRID]
      where [mapF].[MAPID] = @MapID
        and [mapF].[ID] in (select [FLOWID] from @devFlow)
        and [mapO].[ID] is not null

      /*
        Требуется уникальный номер уровня для обеспечения нескольких "колец" в одной карте 
         для него будет использован ID завершенной операции.
         Уровень поднимается только если сл. операция уже есть со старым уровнем (т.е. есть оставшаяся от первого прохода)
      */
    update @Opers set [OPLEVEL] = @NextLevel
    where [LEVELUP] = 1
      and exists (select [oper].[ID]
                  from [dbo].[PR_OPERATION] [oper] with(nolock)
                  where [oper].[DEVICEID] = @DeviceID
                    and [oper].[ORDERID] = @OrdID
                    and [oper].[OPLEVEL] = "@Opers".[OPLEVEL]
                    and [oper].[REVOPERID] = "@Opers".[REVOPERID]
                    and isnull([oper].[PARENTID],0) = isnull(@parentOpID,0)
                    and isnull([oper].[TRMAP_N],0) = isnull(@TrMapN,0)
                    and [oper].[S_S] <> 1000023 /*анулировано*/)
      and not exists (select [oper].[ID]
                      from [dbo].[PR_OPERATION] [oper] with(nolock)
                      where [oper].[DEVICEID] = @DeviceID
                        and [oper].[ORDERID] = @OrdID
                        and [oper].[OPLEVEL] in ("@Opers".[OPLEVEL],@NextLevel)
                        and [oper].[REVOPERID] = "@Opers".[REVOPERID]
                        and isnull([oper].[PARENTID],0) = isnull(@parentOpID,0)
                        and isnull([oper].[TRMAP_N],0) = isnull(@TrMapN,0)
                        and [oper].[S_S] <> 1000023 /*анулировано*/
                        and [oper].[CREATEDBYOPERID] = @NextLevel)

    update @Opers set
       [CANDO] = 0
      ,[SKIPPED] = 1
    where [CONDITION] > 0
      and [CANDO] = 1
      and [dbo].[PR_FLOW_OR_OPER_ALLOWED](null,[REVOPERID],@DeviceID) = 0

    update @Opers set
      [EXISTINGOPERID] = (select top 1 [oper].[ID]
                          from [dbo].[PR_OPERATION] [oper] with(nolock)
                          where [oper].[DEVICEID] = @DeviceID
                            and [oper].[ORDERID] = @OrdID
                            and [oper].[OPLEVEL] = "@Opers".[OPLEVEL]
                            and [oper].[REVOPERID] = "@Opers".[REVOPERID]
                            and isnull([oper].[PARENTID],0) = isnull(@parentOpID,0)
                            and isnull([oper].[TRMAP_N],0) = isnull(@TrMapN,0)
                            and [oper].[S_S] <> 1000023 /*анулировано*/)
    where [CANDO] = 1

    /*KB4558*/
    declare @parentDeviceID int
    select
      @parentDeviceID = [dev].[PARENTID]
    from [dbo].[PR_DEVICE] [dev] with(nolock)
    where [dev].[ID] = @DeviceID

    if @parentDeviceID is not null
    begin
      update @Opers set
        [EXISTINGOPERID]=(select top 1 [oper].[ID]
                          from [dbo].[PR_OPERATION] [oper] with(nolock)
                          where [oper].[ID] in (select [KK].[OPERID] from [dbo].[PR_PARENT_OPERATION] [KK] with(nolock) where [KK].[DEVICEID] = @DeviceID)
                            and [oper].[ORDERID] = @OrdID
                            and [oper].[OPLEVEL] = "@Opers".[OPLEVEL]
                            and [oper].[REVOPERID] = "@Opers".[REVOPERID]
                            and isnull([oper].[PARENTID],0) = isnull(@parentOpID,0)
                            and isnull([oper].[TRMAP_N],0) = isnull(@TrMapN,0)
                            and [oper].[S_S] <> 1000023 /*анулировано*/)
      where [CANDO] = 1
    end

    update @Opers set
      [OPEREXISTS] = 1
    where [CANDO] = 1
      and [EXISTINGOPERID] is not null

    update @Opers set
      [SETUSERID] = @lastUserInProgress
    where [VISMODE] in (1,2,3,4) /* пролонгировать привязку пользователя */
      and [CANDO] = 1
      and [dbo].[PR_OPERTYPE_QUALIFICATION]([OPERID],@lastUserInProgress,@now) = 1

      /*фиксация нормы времени */
    update @Opers set
      [MANHOUR]=(select isnull([roMH].[MANHOUR2],[oprF].[MANHOUR])
                 from [dbo].[PR_OPERATIONS] [oprF] with(nolock)
                   left join [dbo].[PR_DEVICE]      [devi] with(nolock) on [devi].[ID] = @DeviceID
                   left join [dbo].[PR_REV_OVER_MH] [roMH] with(nolock) on [roMH].[OPERID] = [oprF].[ID] and [roMH].[REVID] = [devi].[REVID]
                 where [oprF].[ID] = "@Opers".[OPERID])
    where [CANDO] = 1
      and [OPEREXISTS] = 0

    if (@parentOpID is not null)
    begin
      update @Opers set
         [TODOTEXT]=(select [opTM].[TODO]
                     from [dbo].[PR_OPERATION_TODO_MAP] [opTM] with(nolock)
                     where [opTM].[OPERID] = @parentOpID
                       and [opTM].[MAPOPERID] = "@Opers".[REVOPERID])
        ,[TODOTEXT_SHOWMSG]=(select [opTM].[TODO_CONFIRM]
                             from [dbo].[PR_OPERATION_TODO_MAP] [opTM] with(nolock)
                             where [opTM].[OPERID] = @parentOpID
                               and [opTM].[MAPOPERID] = "@Opers".[REVOPERID])
      where [CANDO] = 1
        and [OPEREXISTS] = 0

      update @Opers set
        [EMPLID]=(select [opTM].[EMPLOYEEID]
                  from [dbo].[PR_OPERATION_TODO_MAP] [opTM] with(nolock)
                  where [opTM].[OPERID] = @parentOpID
                    and [opTM].[MAPOPERID] = "@Opers".[REVOPERID])
      where [CANDO] = 1
        and [OPEREXISTS] = 0

      update @Opers set
        [SETUSERID] = (select top 1 [user].[ID]
                       from [dbo].[DEF_USERS] [user] with(nolock)
                       where [user].[EMPLOYEEID] = "@Opers".[EMPLID])
      where [EMPLID] is not null
    end else
    begin
      update @Opers set
         [TODOTEXT]= (select top 1 [auto].[TODOTEXT]
                      from [dbo].[PR_AUTOCOMMENT] [auto] with(nolock)
                      where [auto].[DEVICEID] = @DeviceID
                        and [auto].[MAPOPERID] = "@Opers".[REVOPERID])
        ,[TODOTEXT_SHOWMSG]=(select top 1 [auto].[TODOTEXT_SHOWMSG]
                             from [dbo].[PR_AUTOCOMMENT] [auto] with(nolock)
                             where [auto].[DEVICEID] = @DeviceID
                               and [auto].[MAPOPERID] = "@Opers".[REVOPERID])
      where [CANDO] = 1
        and [OPEREXISTS] = 0
    end

    declare @newids table ([ID] int,[OPERTYPEID] int,[DEVICEID] int)

    --#region {cd692400-59cd-4713-a861-9d0488ed381f}
    insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CDT],[S_CR],[REVOPERID],[USERINPROGRESS],[OPLEVEL],[TC_ACTION],[TC_MINUTE],[OPERGR],[MANHOUR],[PARENTID],[TRMAP_N],[TODOTEXT],[Q_IN],[CREATEDBYOPERID],[HIDDEN],[HIDDENOTHER],[TODOTEXT_SHOWMSG])
    output inserted.[ID], inserted.[OPERTYPEID], inserted.[DEVICEID] into @newids
      select
         newid()
        ,1000032
        ,@OrdID
        ,@DeviceID
        ,[o].[OPERID]
        ,@now
        ,@UserID
        ,[o].[REVOPERID]
        ,[o].[SETUSERID]
        ,[o].[OPLEVEL]
        ,[o].[TC_ACTION]
        ,[o].[TC_MINUTE]
        ,[o].[SCHEME_GROUP]
        ,[o].[MANHOUR]
        ,@parentOpID
        ,@TrMapN
        ,[o].[TODOTEXT]
        ,@InQuantity
        ,[o].[CREATEDBYOPERID]
        ,[o].[CREATEHIDDEN]
        ,[o].[HIDEOTHER]
        ,[o].[TODOTEXT_SHOWMSG]
      from @Opers [o]
      where [o].[CANDO] = 1
        and [o].[OPEREXISTS] = 0
    --#endregion

    declare @failed table ([OPERID] int,[DEVICEID] int)

    insert into @failed ([OPERID],[DEVICEID])
      select [a].[ID],[a].[DEVICEID]
      from @newids [a]
        left join [dbo].[PR_OPERATIONS] [b] with(nolock) on [b].[ID] = [a].[OPERTYPEID]
      where [b].[OPERTYPE] = 13 /*Special Operation - Item Failed*/

    update [dbo].[PR_OPERATION] set [S_S] = 1000079 /* device failed */ where [PR_OPERATION].[ID] in (select [OPERID] from @failed)
    update [dbo].[PR_DEVICE]    set [S_S] = 1000078 /* production failed */, [FAILED_DT] = @now where [ID] in (select [DEVICEID] from @failed)

    update [dbo].[PR_OPERATION] set
      [HIDDEN] = 0
    where [ORDERID] = @OrdID
      and [DEVICEID] = @DeviceID
      and [HIDDEN] = 1
      and [ID] in (select [o].[EXISTINGOPERID]
                   from @Opers [o]
                   where isnull([o].[CREATEHIDDEN],0) = 0
                     and [o].[EXISTINGOPERID] is not null)

    insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
      select
         getdate(),1,'Document created.',@UserID,20000,1000039,[a].[ID]
        ,replace((select top 1
              [o].*
            ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
            ,'{cd692400-59cd-4713-a861-9d0488ed381f}' [DBG_CODE_LABEL]
          from [dbo].[PR_OPERATION] [o]
          where [o].[ID]=[a].[ID]
          for json path),'\/','/')
      from @newids [a]

    /* те, что пропускать запустить на рекурсию после создания самих операций */
    declare @SkippedOper int
    declare [c] cursor local read_only for
      select [REVOPERID]
      from @Opers
      where [SKIPPED] = 1
    open [c]
    while 1=1
    begin
      fetch next from [c] into @SkippedOper;
      if @@FETCH_STATUS<>0 break;

      if not exists (select [DEVICEID]
                     from [dbo].[PR_DEVICE_SKIPPED_OP]
                     where [DEVICEID] = @DeviceID
                       and [ORDERID] = @OrdID
                       and [OPLEVEL] = @DoneLevel
                       and isnull([TRMAP_N],0) = isnull(@TrMapN,0)
                       and isnull([PARENTID],0) = isnull(@parentOpID,0)
                       and [REVOPERID] = @SkippedOper)
      begin
        insert into [dbo].[PR_DEVICE_SKIPPED_OP] ([DEVICEID],[ORDERID],[OPLEVEL],[REVOPERID],[PARENTID],[TRMAP_N])
             values (@DeviceID,@OrdID,@DoneLevel,@SkippedOper,@parentOpID,@TrMapN)
      end

      begin try
        exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{bf61d9bd-8079-4f18-a2f6-97c415cb1baf}}'
        exec [dbo].[PR_CREATE_NEXT4] @MapID,@SkippedOper,@DoneLevel,@NextLevel,@OrdID,@DeviceID,@lastUserInProgress,@UserID,@parentOpID,@TrMapN,@InQuantity,@ScopeGroup=@ScopeGroup;
        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{9f5222d2-ce09-47c2-8fbd-b842902f2171}}'
      end try
      begin catch
        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{bac7be9f-3bc6-4740-acc4-a353191eaffb}}';
        throw;
      end catch
    end
    close [c];
    deallocate [c];

    --training
    --если операция для обучения, проставится обучаемый сотрудник
    declare @newOperationID int
    declare cur_PR_CREATE_NEXT4 cursor local read_only for
      select [ID] from @newids
    open cur_PR_CREATE_NEXT4 
    while 1=1
    begin
      fetch next from cur_PR_CREATE_NEXT4 into @newOperationID;
      if @@FETCH_STATUS<>0 break;
      begin try
        exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{dbe592b4-0bb3-4751-ab97-88d629fa6fa0}}',@Description=N'Updates data on operations related to training.'
        exec [dbo].[COM_FILL_TRAINING_OPERATION] @newOperationID,@ScopeGroup=@ScopeGroup
        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{50aab220-9942-4d1c-9fa9-c7c1495623cf}}'
      end try
      begin catch
        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{6973acf3-866e-436a-9897-f8fee0e5763e}}';
        throw;
      end catch
    end
    close cur_PR_CREATE_NEXT4;
    deallocate cur_PR_CREATE_NEXT4;
    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{d445c35d-1c8f-4e2d-8bf9-2c36d3d9f36d}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[PR_CREATE_NEXT4]'      [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{1d039a63-b193-4937-9705-0e88a31f33f8}}';
    throw;
  end catch
  set nocount off