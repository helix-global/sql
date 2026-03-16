-- KB5351:2025-06-30: Refactoring.
-- KB5278:2025-07-11: Refactoring. Operation creation logging. Added training filling for {Completed (Err),Failure processed}
-- #AZURE04928:2025-09-26: After returning to production, the [TODOTEXT] field will be transferred from the operation that caused the "troubleshooting" operation to the repeated operation after the repair is complete.
-- #AZURE06081:2025-11-25: Added call tracing.
CREATE procedure [dbo].[PR_NEXT_OPERATION4] @DeviceID int, @DoneOperID int,@ScopeGroup nvarchar(max) = null
as
  set nocount on
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[PR_NEXT_OPERATION4]'   [@ScopeName]
      ,(select
          @DeviceID   [DeviceID]
        ,@DoneOperID [DoneOperID]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)

  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[PR_NEXT_OPERATION4]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    declare @RevID int
    declare @ModTypeID int
    declare @ModelID int
    declare @OrdID int
    declare @DoneOperState int
    declare @MapID int
    declare @lastUserInProgress int
    declare @DeviceState int
    declare @AccMode int
    declare @OrderCount int
    declare @BlockCompl int
    declare @RestQty int
    set @BlockCompl = 0 /*признак 1 блокирует окончание производства, например когда в процедуре создается операция */
    declare @now datetime
    declare @OperCrMode int
    declare @IsOperCrModeByModel int
    declare @ModelOwnerDepID int
    declare @userID int
    declare @employeeID int
    declare @NewOprT table([OPERID] int primary key clustered)

    set @now = getdate()

    select
       @RevID = [dev].[REVID]
      ,@OrdID = [dev].[ORDERID]
      ,@ModTypeID = [mdl].[TYPEID]
      ,@ModelID = [mdl].[ID]
      ,@MapID = [dev].[MAPID]
      ,@DeviceState = [dev].[S_S]
      ,@AccMode = isnull([mdT].[ACCMODE],0)
      ,@OrderCount = [dev].[ORDQUANTITY]
      ,@RestQty = [dev].[RESQUANTITY]
      ,@OperCrMode = isnull([mdl].[OPERCRMODE],isnull([mdT].[OPERCRMODE],0))
      ,@IsOperCrModeByModel = (case when isnull([mdl].[OPERCRMODE],0)>0 then 1 else 0 end)
      ,@ModelOwnerDepID = [mdl].[DEPID]
    from [dbo].[PR_DEVICE] [dev] with(nolock)
      left join [dbo].[PR_MODELS]    [mdl] with(nolock) on [mdl].[ID]=[dev].[MODELID]
      left join [dbo].[PR_MODELTYPE] [mdT] with(nolock) on [mdT].[ID]=[mdl].[TYPEID]
    where [dev].[ID]=@DeviceID;

    if @DoneOperID is not null
    begin
      select
         @DoneOperState = [A].[S_S]
        ,@userID = [A].[S_MR]
      from [dbo].[PR_OPERATION] [A] with(nolock)
      where [A].[ID]=@DoneOperID

      if @DoneOperState in (1000013,1000019) /*cmpl, cmpl.w.err*/
      begin
        exec [dbo].[PR_OPERATION_UPD_LIST_PARAMS2] @DeviceID, @ModTypeID
        exec [dbo].[PR_UPDATE_INDEXED_PARAMS] @DoneOperID
      end

      --Old
      --exec PR_CHECK_EQ_WORKCYCLES @DoneOperID, 0

      --New KB2654:
      --Disabled per KB4734 on 2025-10-17, new notification logic
      --exec [dbo].[PR_CHECK_EQ_WORKCYCLES2] @DoneOperID, 0
    end

    if @DeviceState in (1000010/*shipped*/,1000085/*shipped srv*/,1000039 /*srv completed*/,1000022/*prod compl*/, 1000077 /*installed*/,1000078/*failed*/)
    begin
      --if @DoneOperID is not null and @DeviceState in (1000010/*shipped*/,1000022/*prod compl*/) --was before 
      if @DoneOperID is not null and @DeviceState in (1000010/*shipped*/,1000022/*prod compl*/, 1000085/*shipped srv for KB2742 */)
      begin
        --exec MSG_PREPARE_FILENOTIFICATION @DeviceID, @userID -- was before KB4213
        exec [dbo].[MSG_PREPARE_FILENOTIFICATION] @DeviceID, @userID, @DoneOperID /* KB4213 - for analize type of Order (ProductionOrder or ServiceOrder)  */
      end
      exec [trace].[SPTraceLeave] @ScopeName=N'{code:{d7138da3-eac8-4d84-8096-c357dc3d43f4}}'
      return
    end

    if @DoneOperID is null  /*первый запуск с заказа */
    begin
      if (@RevID is null)
      begin
        exec [trace].[SPTraceEvent] @Message=N'Revision is empty. Unable to run production.',@ScopeName=N'{code:{5eef3b3f-6aab-4171-99c1-54c90951e001}}'
        raiserror('Revision is empty. Unable to run production.[L=pr_empty_rev',15,0);
        return
      end

      if not exists (select [mapF].[ID]
                     from [dbo].[PR_MAP_FLOW] [mapF] with(nolock)
                     where [mapF].[MAPID]=@MapID
                       and [mapF].[OP_FROM] is null
                       and [mapF].[OP_TO] is not null)
      begin
        exec [trace].[SPTraceEvent] @Message=N'Production map is empty. Unable to run production.',@ScopeName=N'{code:{b6012a2a-69cc-464e-9779-8da4161688f2}}'
        raiserror('Production map is empty. Unable to run production.[L=pr_empty_map',15,0); 
        return
      end

      if @OperCrMode > 0
      begin
        declare @alreadyCreated int

        select distinct @alreadyCreated = count([dev].[ID])
        from [dbo].[PR_DEVICE] [dev] with(nolock)
          left join [dbo].[PR_MODELS] [mdl] with (nolock) on [mdl].[ID]=[dev].[MODELID]
        where [dev].[ORDERID] = @OrdID
          and [mdl].[TYPEID] = @ModTypeID
          and (@IsOperCrModeByModel=1 or [mdl].[ID] not in (select [ID] from [PR_MODELS] where [TYPEID]=@ModTypeID and isnull([OPERCRMODE],0)>0))
          and (@IsOperCrModeByModel<>1 or [mdl].[ID] = @ModelID)
          and [dev].[S_S] <> 1000078 /*failed*/
          and [dev].[S_S] <> 1000101 /*canceled*/ 
          and exists     (select [opr].[ID] from [dbo].[PR_OPERATION] [opr] with(nolock) where [opr].[DEVICEID]=[dev].[ID])
          and not exists (select [opr].[ID]
                          from [dbo].[PR_OPERATION] [opr] with(nolock)
                          where ([opr].[DEVICEID] = [dev].[ID])
                            and ([opr].[COMPLETED_DT] is not null or [opr].[USERINPROGRESS] is not null or [opr].[S_S] = 1000018/*failure*/))

        if @alreadyCreated >= @OperCrMode
        begin
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{c3181654-964d-477f-b925-59ea058d6fa1}}'
          return
        end
      end

      if @DeviceState <> 1000069/*postponed KB2653*/
      begin
        begin try
          exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{5747a0c8-9886-4945-8f05-7ab766e81b87}}'
          exec [dbo].[PR_CREATE_NEXT4] @MapID,null,0,0,@OrdID,@DeviceID,null,0,null,null,@OrderCount,@ScopeGroup=@ScopeGroup
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{48e0486d-a5f4-4c25-8986-922abacfe8a1}}'
        end try
        begin catch
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{801d0965-c2af-4ce1-b629-dd676856cad7}}';
          throw;
        end catch
      end

      exec [dbo].[PR_UPDATE_PRTIME] @DeviceID
      exec [dbo].[PR_UPDATE_LASTSRVORDID] @OrdID

      if (@DeviceState=1000057/*Prepared*/ and exists (select * from [dbo].[PR_OPERATION] with(nolock) where [DEVICEID]=@DeviceID and [S_S]=1000032/*Pending*/))
      begin
        update [dbo].[PR_DEVICE] set [S_S]=1000029/*Pending Production*/ where [ID]=@DeviceID
      end
    end

    if @DoneOperID is not null
    begin
      declare @repReasonEmtpy int
      declare @ParentOperID int
      declare @OperationSpecialType int --a2l://doc/?ClassLabel=def_enumeration&OID=1000026
      declare @todoId int
      declare @DoneOperType int
      declare @DoneRevOper int
      declare @orderType int
      declare @orderID int
      declare @DoneLevel int
      declare @ReRunAll int
      declare @FreeRepair int
      declare @checkDevID int
      declare @oq_out int
      declare @oq_in int
      declare @servMap int
      declare @frID0 int
      declare @trMapType int
      declare @trMapID int
      declare @trMapN int
      declare @qParent int
      declare @qTopParent int
      declare @existingFRID int
      declare @q_in_nullable int
      declare @q_out_nullable int
      declare @ittFailed int
      declare @checkEqID int

      select
         @DoneOperState = [opr].[S_S]
        ,@ParentOperID = [opr].[PARENTID]
        ,@repReasonEmtpy = case when [opr].[REPAIRREASON] is null then 1 else 0 end
        ,@OperationSpecialType = [opF].[OPERTYPE]
        ,@todoId = [opr].[TODOID]
        ,@DoneOperType = [opr].[OPERTYPEID]
        ,@DoneRevOper = [opr].[REVOPERID]
        ,@orderType = isnull([ord].[ORDERTYPE],0)
        ,@orderID = [opr].[ORDERID]
        ,@userID = [opr].[S_MR]
        ,@lastUserInProgress = isnull([opr].[LASTUSERINPROGRESS],[opr].[USERINPROGRESS])
        ,@DoneLevel = isnull([opr].[OPLEVEL],0)
        ,@ReRunAll = isnull([opr].[RERUNALL],0)
        ,@FreeRepair = isnull([opr].[FREETR],0)
        ,@checkDevID = [opr].[DEVICEID]
        ,@oq_out = isnull([opr].[PREP_RESULT],0)
        ,@oq_in = isnull([opr].[Q_IN],1)
        ,@q_in_nullable = [opr].[Q_IN]
        ,@q_out_nullable = [opr].[PREP_RESULT]
        ,@servMap = [ord].[SERVMAP]
        ,@frID0 = [opr].[FAILUREREPORTID]
        ,@trMapType = isnull([opr].[TRTYPE],0)
        ,@trMapID = [opr].[TRMAPID]
        ,@trMapN = isnull([opr].[TRMAP_N],0)
        ,@qParent = [dev].[Q_PARENT]
        ,@qTopParent = [dev].[Q_TOPPARENT]
        ,@existingFRID = [opr].[FAILUREREPORTID]
        ,@ittFailed = isnull([opr].[ITEMFAILED],0)
        ,@checkEqID = [opr].[EQID]
      from [dbo].[PR_OPERATION] [opr] with(nolock)
        left join [dbo].[PR_PRORDER]       [ord] with(nolock) on [ord].[ID]=[opr].[ORDERID]
        left join [dbo].[PR_DEVICE]        [dev] with(nolock) on [dev].[ID]=[opr].[DEVICEID]
        left join [dbo].[PR_OPERATIONS]    [opF] with(nolock) on [opF].[ID]=[opr].[OPERTYPEID]
        left join [dbo].[PR_OPERATIONS_GR] [opG] with(nolock) on [opG].[ID]=[opF].[OPERGRID]
      where [opr].[ID] = @DoneOperID;

    --если завершена, проставить в тренингах эту операцию
      if @DoneOperState in (
         1000013 -- Completed
        ,1000019 -- Completed (Err)     --KB5278
        --#AZURE06081:2025-11-25:Commented as BUG,1000038 -- Failure processed   --KB5278
        )
      begin
        begin try
          exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{f6538d85-4e35-466e-91a6-57b13b9567c7}}'
          exec [dbo].[COM_FILL_TRAINING_OPERATION_MODE2] @DoneOperID, @userID,@ScopeGroup=@ScopeGroup
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{0d9420dc-0278-4465-9f7f-3e0d4af22f37}}'
        end try
        begin catch
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{7b8eac62-667d-47ed-9638-ea5d54891f4d}}';
          throw;
        end catch
      end

      --проверка, требуется ли согласование тренера (если операция в тренинге)
      --если требуется, следующая операция создастся только после утверждения тренером
      if [dbo].[COM_TRAINING_OPERATION_CAN_CREATE_NEXT](@DoneOperID, @userID)=0
      begin
        --print '#WNext operation will not be created until trainer approves current one'
        --KB2484
        print '#WBe aware, that training need approval to !'
        if @DoneOperState = 1000018  /*failure*/
        begin
          if @repReasonEmtpy = 1
          begin
            exec [trace].[SPTraceEvent] @Message=N'Please set failure description.',@ScopeName=N'{code:{7369e8b2-470c-48fe-a6bd-c5ea551b6f5d}}'
            raiserror('Please set failure description.[L=pr_set_failure_desc',15,0);
            return
          end
        end

        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{24a6abd0-ebb1-4310-bcb0-effd5b712f4b}}'
        return
      end

      if @orderType in (1,2) and @servMap is not null
      begin
        set @MapID = @servMap
        set @OrdID = @orderID
      end

      if (@checkDevID is null) /*preparatory*/
      begin
        if @DoneOperState = 1000018 and @checkEqID is null /*failure*/
        begin
          exec [trace].[SPTraceEvent] @Message=N'Cannot set failure for preparatory operation.',@ScopeName=N'{code:{09a2858d-04f1-4ddd-b3ee-f8db591660e2}}'
          raiserror('Cannot set failure for preparatory operation.',15,0);
        end

        if @DoneOperState = 1000079 /* device failed */
        begin
          exec [trace].[SPTraceEvent] @Message=N'Cannot set failure for preparatory operation.',@ScopeName=N'{code:{380c746b-3da3-4c02-927b-eadf30048340}}'
          raiserror('Cannot set failure for preparatory operation.',15,0);
        end

        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{d3da52b8-89da-4d73-9734-9b2207b3ef68}}'
        return
      end

      if @orderType = 0 and @OperCrMode > 0
      begin
        exec [dbo].[PR_CHECK_AND_RUN_DELAYED] @DeviceID, @OrdID
      end

      if @orderType in (0,1) and @ittFailed > 0 and @DoneOperState in (1000013,1000019) 
      begin
        exec [dbo].[PR_OPER_DO_FAILED] @DoneOperID, @userID
        select
          @DoneOperState = [opr].[S_S]
        from [dbo].[PR_OPERATION] [opr] with(nolock)
        where [opr].[ID]=@DoneOperID;
      end

      if (@AccMode in (2) /*SN + Qty*/ and @DoneOperState in (1000013,1000019) )
      begin
        select @RestQty = @oq_out
        update [dbo].[PR_DEVICE] set
          [RESQUANTITY] = @RestQty
        where [ID] = @checkDevID
          and isnull([RESQUANTITY],0) <> @RestQty
      end

      if (@AccMode in (1,4,5) and @DoneOperState in (1000013,1000019) /*cmpl, cmpl.w.err*/)
      begin
        if @orderType in (1,2) /*19.04.16 для серв заказа общее кол-во нужно брать со строки сервисного заказа*/
        begin
          select
            @RestQty = isnull([ordS].[QTY],1)
          from [dbo].[PR_PRORDER_SERVICE] [ordS] with(nolock)
          where [ordS].[ORDERID] = @OrdID
            and [ordS].[DEVICEID] = @DeviceID
        end

        if @oq_out < 1
        begin
          exec [trace].[SPTraceEvent] @Message=N'Result quantity must be more than zero.',@ScopeName=N'{code:{70a99de2-934f-4a49-9fbd-ba11b75a1d71}}'
          raiserror('Result quantity must be more than zero.',15,0);
          return
        end
        /*
        if @oq_out > @RestQty
        begin
           raiserror('Result quantity must be smaller or equal than ordered quantity.',15,0);
           set nocount off
           return
        end
        */

        if (@AccMode in (1))
        begin
          set @RestQty = @oq_in
        end

        declare @NeedCreate int 
        set @NeedCreate = @RestQty - @oq_out

        if (@NeedCreate < 0)
        begin
          if (@AccMode in (1))
          begin
            /* если получилось больше, то отделения операции уже не нужно, а результирующий остаток в изделии нужно увеличить */
            update [dbo].[PR_DEVICE] set
              [RESQUANTITY] = isnull([RESQUANTITY],1) + [dbo].[PR_DEVICE_CALC_RESQTY_BYOPERATIONS]([ID],1)
            where [ID] = @checkDevID
          end

          if (@AccMode in (5))  /*KB3767*/
          begin
            select @RestQty = @oq_out
            update [dbo].[PR_DEVICE] set
              [RESQUANTITY] = @RestQty
            where [ID] = @checkDevID
              and isnull([RESQUANTITY],0) <> @RestQty
          end
        end
        else if (@NeedCreate > 0)
        begin
          set @BlockCompl = 1
          declare @operToDevID int
          set @operToDevID = @checkDevID
          if @AccMode = 1
          begin
            set @RestQty = @RestQty - @NeedCreate

            /*создается операция на остаток с новым OPLEVEL, но на то-же изделие */
            --#region {d6fbbd89-8fd8-4d7b-a80d-39d44f28d55d}
            delete from @NewOprT
            insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CR],[S_CDT],[REVOPERID],[OPLEVEL],[Q_IN],[Q_PARENT])
            output inserted.ID into @NewOprT
              select
                 newid()
                ,1000032
                ,[opr].[ORDERID]
                ,@operToDevID
                ,[opr].[OPERTYPEID]
                ,[opr].[S_MR]
                ,@now
                ,[opr].[REVOPERID]
                ,[opr].[ID]
                ,@NeedCreate
                ,@DoneOperID
              from [dbo].[PR_OPERATION] [opr]
              where [opr].[ID] = @DoneOperID

            insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
              select
                 getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
                ,replace((select top 1
                     [o].*
                    ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                    ,'{d6fbbd89-8fd8-4d7b-a80d-39d44f28d55d}' [DBG_CODE_LABEL]
                  from [dbo].[PR_OPERATION] [o]
                  where [o].[ID]=[a].[OPERID]
                  for json path),'\/','/')
              from @NewOprT [a]
            --#endregion
          end
          if @AccMode in (4,5) and @orderType = 0
          begin
            /* создается новый серийный номер с суффиксом и остаточная сумма вешается на него */
            set @BlockCompl = 0 /*при этом блокировать исходный не нужно*/

            declare @nextSuff int
            declare @newSN nvarchar(50)
            if @AccMode = 4
            begin
              select @nextSuff = max(isnull([dev].[Q_SUFF],0)) from [dbo].[PR_DEVICE] [dev] with(nolock) where [dev].[ORDERID] = @orderID and [dev].[Q_PARENT] = @checkDevID
              select @newSN = [dev].[SN] from [dbo].[PR_DEVICE] [dev] with(nolock) where [dev].[ID] = @checkDevID
            end
            else if @AccMode = 5
            begin
              select @nextSuff = max(isnull([dev].[Q_SUFF],0)) from [dbo].[PR_DEVICE] [dev] with(nolock) where [dev].[ORDERID] = @orderID
              select @newSN = [dev].[SN] from [dbo].[PR_DEVICE] [dev] with(nolock) where [dev].[ID] = isnull(@qTopParent,@checkDevID)
             end
            set @nextSuff = isnull(@nextSuff,0) + 1
            set @newSN = @newSN + '-'+ltrim(rtrim(str(@nextSuff)))

            insert into [dbo].[PR_DEVICE] ([GID],[S_S],[S_CR],[S_CDT],[ORDERID],[MODELID],[REVID],[MAPID],[SORDERID]
                                    ,[ORDERROWID],[Q_SUFF],[Q_PARENT],[Q_OPERID],[SN],[Q_TOPPARENT]
                                    ,[URGENCY],[PRRESTTIME],[ORDQUANTITY],[RESQUANTITY])
              select
                 newid()
                ,[dev].[S_S]
                ,@userID
                ,@now
                ,[dev].[ORDERID]
                ,[dev].[MODELID]
                ,[dev].[REVID]
                ,[dev].[MAPID]
                ,[dev].[SORDERID]
                ,[dev].[ORDERROWID]
                ,@nextSuff
                ,[dev].[ID]
                ,@DoneOperID
                ,@newSN
                ,isnull([dev].[Q_TOPPARENT],[dev].[ID])
                ,[dev].[URGENCY]
                ,[dev].[PRRESTTIME]
                ,@NeedCreate,@NeedCreate
              from [dbo].[PR_DEVICE] [dev]
              where [dev].[ID] = @checkDevID

            set @operToDevID = @@identity
            set @RestQty = @RestQty - @NeedCreate
            update [dbo].[PR_DEVICE] set
              [RESQUANTITY] = @RestQty
            where [ID] = @checkDevID

            insert into [dbo].[PR_PARENT_OPERATION] ([DEVICEID],[OPERID])
              select @operToDevID,[M].[ID]
              from (
                select [opr].[ID]
                from [dbo].[PR_OPERATION] [opr] with(nolock)
                where [opr].[DEVICEID] = @checkDevID
                  and [opr].[ORDERID] = @orderID
                   ) [M]
              where [M].[ID] < @DoneOperID

            insert into [dbo].[PR_PARENT_OPERATION] ([DEVICEID],[OPERID])
              select
                 @operToDevID
                ,[oprP].[OPERID]
              from [dbo].[PR_PARENT_OPERATION] [oprP] with(nolock)
              where [oprP].[DEVICEID] = @checkDevID

             /*KB3453*/
            insert into [dbo].[PR_DEVICE_OPT]([GID],[S_CR],[S_CDT],[DEVICEID],[OPTID],[OPTSN],[QUANTITY],[BOMID])
              select
                 newid()
                ,@userID
                ,@now
                ,@operToDevID
                ,[devO].[OPTID]
                ,[devO].[OPTSN]
                ,[devO].[QUANTITY]
                ,[devO].[BOMID]
              from [dbo].[PR_DEVICE_OPT] [devO] with(nolock)
              where [devO].[DEVICEID] = @checkDevID

            --#region {f6f3d65a-04c9-45c6-aacd-4aede48726e2}
            delete from @NewOprT
            insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CR],[S_CDT],[REVOPERID],[OPLEVEL],[Q_IN],[Q_PARENT])
            output inserted.ID into @NewOprT
              select
                 newid()
                ,1000032
                ,[opr].[ORDERID]
                ,@operToDevID
                ,[opr].[OPERTYPEID]
                ,[opr].[S_MR]
                ,@now
                ,[opr].[REVOPERID]
                ,[opr].[OPLEVEL]
                ,@NeedCreate
                ,@DoneOperID
              from [dbo].[PR_OPERATION] [opr]
              where [opr].[ID] = @DoneOperID

            insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
              select
                 getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
                ,replace((select top 1
                     [o].*
                    ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                    ,'{f6f3d65a-04c9-45c6-aacd-4aede48726e2}' [DBG_CODE_LABEL]
                  from [dbo].[PR_OPERATION] [o]
                  where [o].[ID]=[a].[OPERID]
                  for json path),'\/','/')
              from @NewOprT [a]
            --#endregion
          end
        end
      end

      if (@DoneOperState = 1000079) /* device failed */
      begin
        update [dbo].[PR_DEVICE] set
           [S_S] = 1000078 /* production failed */
          ,[FAILED_DT] = @now
        where [ID] = @checkDevID

        delete from [dbo].[PR_OPERATION]
        where [DEVICEID] = @checkDevID
          and [ORDERID] = @orderID
          and [S_S] = 1000032/*pending*/

        declare @ItemFailedTypeID int
        select top 1
          @ItemFailedTypeID = [opF].[ID]
        from [PR_OPERATIONS] [opF] with(nolock)
        where [opF].[MTID] = @ModTypeID
          and [opF].[OPERTYPE] = 12

        if @ItemFailedTypeID > 0
        begin
          --#region {23651d9d-adc1-4df0-9cb1-2a120e7474bc}
          delete from @NewOprT
          insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CR],[S_CDT],[PARENTID],[SPECIALTYPE],[Q_IN])
          output inserted.ID into @NewOprT
            select
               newid()
              ,1000032
              ,@OrdID
              ,@DeviceID
              ,@ItemFailedTypeID
              ,[opr].[S_MR]
              ,@now
              ,[opr].[ID]
              ,12
              ,@q_in_nullable
            from [dbo].[PR_OPERATION] [opr]
            where [opr].[ID] = @DoneOperID;

          insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
            select
                getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
                ,replace((select top 1
                      [o].*
                    ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                    ,'{23651d9d-adc1-4df0-9cb1-2a120e7474bc}' [DBG_CODE_LABEL]
                  from [dbo].[PR_OPERATION] [o]
                  where [o].[ID]=[a].[OPERID]
                  for json path),'\/','/')
            from @NewOprT [a]
          --#endregion
        end

        exec [dbo].[PR_UPDATE_ORDERS] @checkDevID, null, null, null
        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{0379bcc2-3648-44fd-b639-b1af7fec716e}}'
        return
      end

      if (@DoneOperState = 1000018) and (@OperationSpecialType = 1)
      begin
        exec [trace].[SPTraceEvent] @Message=N'Cannot set failure for troubleshooting operation.',@ScopeName=N'{code:{59e286b1-2916-419c-8134-213608ab9b41}}'
        raiserror('Cannot set failure for troubleshooting operation.[L=pr_cannot_set_trouble',15,0);
        return
      end

      if (@DoneOperState = 1000019) and (@OperationSpecialType = 1)
      begin
        exec [trace].[SPTraceEvent] @Message=N'Cannot set complete with errors for troubleshooting operation.',@ScopeName=N'{code:{b00e3f8c-414e-475a-ba3e-bfee2a228320}}'
        raiserror('Cannot set complete with errors for troubleshooting operation.[L=pr_cannot_set_trouble',15,0);
        return
      end

      if @DoneOperState = 1000018  /*failure*/
      begin
        if @repReasonEmtpy = 1
        begin
          exec [trace].[SPTraceEvent] @Message=N'Please set failure description.',@ScopeName=N'{code:{98e5482d-16a1-406c-b01e-7a02e137dfc3}}'
          raiserror('Please set failure description.[L=pr_set_failure_desc',15,0);
          return
        end
        update [dbo].[PR_OPERATION] set
          [REPORTEDERRORUSER] = @userID
        where [ID] = @DoneOperID 
      end

      if (@OperationSpecialType = 1) and (@DoneOperState in (1000013,1000019))  /* завершен troubleshooting*/
      begin
        if @FreeRepair = 1
        begin
          goto ExitLabel
        end

        if @ReRunAll = 1 and @orderType = 0
        begin
          update [PR_OPERATION] set
             [S_S] = 1000023 /*canceled*/
            ,[S_MDT] = getdate() /*18.01.19 KB369*/
          where [DEVICEID] = @DeviceID
            and [ORDERID] = @orderID /*and ISNULL([OPLEVEL],0) = @DoneLevel*/
            and [ID] <> @DoneOperID

          /*18.01.19 KB369*/
          update [dbo].[PR_OPERATION_TIME] set
            [PR_OPERATION_TIME].[DEND] = getdate()
          where [PR_OPERATION_TIME].[OPERID] in (select [opr].[ID]
                                                 from [PR_OPERATION] [opr]
                                                 where [opr].[DEVICEID] = @DeviceID
                                                   and [opr].[ORDERID] = @orderID
                                                   and [opr].[ID] <> @DoneOperID)
            and [PR_OPERATION_TIME].[DEND] is null

          /*сменить статус ранее установленных компонент на uninstalled*/
          exec [dbo].[PR_CANCEL_INSTALLATION] @DeviceID, @orderID

          --#region {6c92f4ca-a348-44f6-8038-254a2c4deea3}
          delete from @NewOprT
          insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CDT],[REVOPERID],[OPLEVEL],[TC_ACTION],[TC_MINUTE],[OPERGR],[Q_IN])
          output inserted.ID into @NewOprT
            select
               newid()
              ,1000032
              ,@orderID
              ,@DeviceID
              ,[map].[OPERID]
              ,@now
              ,[map].[ID]
              ,@DoneOperID
              ,[map].[TC_ACTION]
              ,[map].[TC_MINUTE]
              ,[map].[SCHEME_GROUP]
              ,@q_in_nullable
            from [dbo].[PR_MAP_OPER] [map] with(nolock)
              left join [dbo].[PR_MAP_FLOW] [flw] with(nolock) on [flw].[OP_TO] = [map].[ID]
            where [map].[MAPID] = @MapID
              and ([flw].[ID] is null or [flw].[OP_FROM] is null)
              and not exists (select [opr].[ID]
                              from [dbo].[PR_OPERATION] [opr] with(nolock)
                              where [opr].[DEVICEID] = @DeviceID
                                and [opr].[ORDERID] = @OrdID
                                and [opr].[OPLEVEL] = @DoneOperID
                                and [opr].[S_S] <> 1000023)

          insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
            select
                getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
               ,replace((select top 1
                     [o].*
                    ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                    ,'{6c92f4ca-a348-44f6-8038-254a2c4deea3}' [DBG_CODE_LABEL]
                  from [dbo].[PR_OPERATION] [o]
                  where [o].[ID]=[a].[OPERID]
                  for json path),'\/','/')
            from @NewOprT [a]
          --#endregion
          goto ExitLabel
        end

        /*если в TODO нет незавершенных операций заново создать операцию с 
        которой пошли на troubleshooting (если производственный приказ)
        иначе - следующую по TODO
        */

        /*31.08.2018 это проставляется при закрытии самой операции, но добавил здесь дополнительное заполнение на случай ошибок*/
        update [dbo].[PR_OPERATION_TODO] set
          [DONEID] = (select [opr].[ID]
                      from [dbo].[PR_OPERATION] [opr] with(nolock)
                      where [opr].[DEVICEID] = @DeviceID
                        and [opr].[PARENTID] = [PR_OPERATION_TODO].[OPERID]
                        and [opr].[TODOID] = [PR_OPERATION_TODO].[ID]
                        and [opr].[S_S] in (1000013,1000019,1000018))
        where [OPERID] = @DoneOperID
          and [PR_OPERATION_TODO].[DONEID] is null

        update [dbo].[PR_OPERATION_TODO] set
          [DONEID] = null
        where [OPERID] = @DoneOperID
          and not exists (select [opr].[ID]
                          from [dbo].[PR_OPERATION] [opr]
                          where [opr].[DEVICEID] = @DeviceID
                            and [opr].[ID] = [PR_OPERATION_TODO].[DONEID])

        declare @NotCmplTroubleOps int = 0

        if @trMapType = 1 /*завершен MAP troubleshooting */
        begin
          if @trMapID is null
          begin
            exec [trace].[SPTraceEvent] @Message=N'Cannot proceed troubleshooting operations without service map.',@ScopeName=N'{code:{2f2cc229-0a15-457b-bbd2-1cf0b24d78fc}}'
            raiserror('Cannot proceed troubleshooting operations without service map.[L=pr_cannot_trouble_map_empty',15,0);
            return
          end

          if [dbo].[PR_ALL_OP_DONE3](@trMapID,@DeviceID,@orderID,@DoneLevel,@DoneOperID,@trMapN) = 0
          begin
            set @NotCmplTroubleOps = 1
          end
        end
        else /* classic troubleshooting */
        begin
          select
            @NotCmplTroubleOps = count(*)
          from [dbo].[PR_OPERATION_TODO] [todo]
          where [todo].[OPERID] = @DoneOperID
            and [todo].[DONEID] is null
        end

        if (@NotCmplTroubleOps > 0) /* есть что делать по troubleshooting */
        begin
          if @trMapType = 1 /*map*/
          begin
            begin try
              exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{2c90f91a-fd50-4a2e-9d71-7f6a039314e5}}'
              exec [dbo].[PR_CREATE_FIRST] @DeviceID,@orderID,@now,@trMapID,@OrderCount,@DoneOperID,@trMapN,@ScopeGroup=@ScopeGroup
              exec [trace].[SPTraceLeave] @ScopeName=N'{code:{9b83dd47-65a8-4c62-9c25-c8609f0d9259}}'
            end try
            begin catch
              exec [trace].[SPTraceLeave] @ScopeName=N'{code:{18687a29-57f9-4304-bb13-b14e337aaf8d}}';
              throw;
            end catch
          end
          else /*classic*/
          begin
            declare @nextord int
            select @nextord = min([todo].[ORDERPOS])
            from [dbo].[PR_OPERATION_TODO] [todo] with(nolock)
            where [todo].[OPERID] = @DoneOperID
              and [todo].[DONEID] is null

            --#region {4301523d-90b2-4b8d-b685-7ae4577616ca}
            delete from @NewOprT
            insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CDT],[S_CR],[PARENTID],[TODOTEXT],[TODOID],[USERINPROGRESS],[Q_IN],[TODOTEXT_SHOWMSG])
            output inserted.ID into @NewOprT
              select
                 newid()
                ,1000032
                ,@orderID
                ,@DeviceID
                ,[todo].[OPERATIONID]
                ,@now
                ,@userID
                ,@DoneOperID
                ,[todo].[TODO]
                ,[todo].[ID]
                ,(select top 1 [user].[ID] from [dbo].[DEF_USERS] [user] where [user].[EMPLOYEEID] = [todo].[EMPLOYEEID])
                ,isnull(@q_out_nullable,@q_in_nullable)
                ,[todo].[TODO_CONFIRM]
              from [dbo].[PR_OPERATION_TODO] [todo]
              where [todo].[OPERID] = @DoneOperID
              /*and [todo].[ORDERPOS] = @nextord*/
                and [todo].[ORDERPOS] = (select min([K].[ORDERPOS])
                                         from [dbo].[PR_OPERATION_TODO] [K] with(nolock)
                                         where [K].[OPERID] = @DoneOperID
                                           and [K].[DONEID] is null
                                           and isnull([K].[TRBRANCH],-22) = isnull([todo].[TRBRANCH],-22)
                                         )
                and not exists (select [oper].[ID]
                                from [dbo].[PR_OPERATION] [oper]
                                where [oper].[DEVICEID] = @DeviceID
                                  and [oper].[PARENTID] = @DoneOperID
                                  and [oper].[TODOID] = [todo].[ID]
                                  and [oper].[S_S] <> 1000023)

            insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
              select
                 getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
                ,replace((select top 1
                     [o].*
                    ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                    ,'{4301523d-90b2-4b8d-b685-7ae4577616ca}' [DBG_CODE_LABEL]
                  from [dbo].[PR_OPERATION] [o]
                  where [o].[ID]=[a].[OPERID]
                  for json path),'\/','/')
              from @NewOprT [a]
            --#endregion

            if (@nextord is not null and @orderType in (1,2)) /*service order*/
            begin
              update [dbo].[PR_DEVICE]  set [S_S] = 1000011/*In Service*/ ,[SCOMPLETED_DT] = null where [ID] = @DeviceID and [S_S] = 1000039/*Service Completed*/
              update [dbo].[PR_PRORDER] set [S_S] = 1000035/*In Progress*/, [COMPLETED_DT] = null where [ID] = @orderID  and [S_S] = 1000036/*Completed*/ 
            end
          end
        end

        if (@NotCmplTroubleOps = 0) /* по troubleshooting больше делать нечего */
        begin
          update [dbo].[PR_OPERATION] set
            [RETURNTR] = 0
          where [ID] = @DoneOperID
            and [RETURNTR] <> 0;

          /*if (@orderType = 0) and (@ParentOperID is not null)*/
          if (@orderType in (0,1)) and (@ParentOperID is not null) /*KB2264*/
          begin
            /*возврат в производство (одинаковый для classic и map )*/
            --#region {e89a372f-1b3b-46d0-806c-376e62eea533}
            delete from @NewOprT
            insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CDT],[REVOPERID]
                                      ,[RETURNAFTERTROUBLEID],[OPLEVEL],[OPERGR],[USERINPROGRESS],[Q_IN],[USERINTRAINING])
            output inserted.ID into @NewOprT
              select
                 newid()
                ,1000032
                ,@OrdID
                ,@DeviceID
                ,[oper].[OPERTYPEID]
                ,@now
                ,[oper].[REVOPERID]
                ,@DoneOperID
                ,[oper].[OPLEVEL]
                ,[oper].[OPERGR]
                ,case isnull([oprG].[VISTYPE],0) when 0 then null else [oper].[REPORTEDERRORUSER] end
                ,isnull(@q_out_nullable,[oper].[Q_IN])
                ,[oper].[USERINTRAINING]
              from [dbo].[PR_OPERATION] [oper]
                left join [dbo].[PR_OPERATIONS]    [oprF] on [oprF].[ID] = [oper].[OPERTYPEID]
                left join [dbo].[PR_OPERATIONS_GR] [oprG] on [oprG].[ID] = [oprF].[OPERGRID]
              where [oper].[ID] = @ParentOperID
                and not exists (select [o].[ID]
                                from [dbo].[PR_OPERATION] [o]
                                where [o].[DEVICEID] = @DeviceID
                                  and [o].[RETURNAFTERTROUBLEID] = @DoneOperID
                                  and [o].[S_S] <> 1000023);

            insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
              select
                 getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
                ,replace((select top 1
                     [o].*
                    ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                    ,'{e89a372f-1b3b-46d0-806c-376e62eea533}' [DBG_CODE_LABEL]
                  from [dbo].[PR_OPERATION] [o]
                  where [o].[ID]=[a].[OPERID]
                  for json path),'\/','/')
              from @NewOprT [a]
            --#endregion

            update [dbo].[PR_OPERATION] set [TROUBLEEXIT] = 1 where [ID] = @ParentOperID;
          end
          else if (@orderType = 0) and (@ParentOperID is null) /* этот troubleshooting заложен в карте */
          begin
            goto BackLabel
          end

          /*if (@orderType in (1,2))*/ /*service order*/
          if (@orderType in (1,2) and (@ParentOperID is null)) /* KB2264 service order - ремонт по простому troubleshooting без карты*/
          begin
            declare @haveUnclosed int
            select  @haveUnclosed = count(*)
            from [dbo].[PR_OPERATION] [opr]
            where [opr].[DEVICEID] = @DeviceID 
              and [opr].[PARENTID] = @DoneOperID
              and [opr].[S_S] in (1000031,1000032,1000033) /*in progress,pednig,postponed*/

            if isnull(@haveUnclosed,0) = 0
            begin
              exec [dbo].[PR_DEVICE_COMPLETED] @DeviceID, @orderID ,@now ,@userID
            end
          end
        end

        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{7c188f41-a9a2-4158-a0a4-13e2ad6421f0}}'
        return
      end

      if @ParentOperID is null /*операция НЕ по troubleshooting */
      begin
        if (@DoneOperState in (1000013,1000019))
        begin
          if @OperationSpecialType in (8,18) /*disassembly and recycling*/
          begin
            update [dbo].[PR_DEVICE] set [S_S] = 1000078 /* production failed */, [FAILED_DT] = @now where [ID] = @checkDevID
            /*KB928*//*if (@orderType in (1,2))*/ /*service order*/
            update [dbo].[PR_DEVICE] set [S_S] = 1000158 /* recycled */ where [ID] = @checkDevID
            delete from [dbo].[PR_OPERATION] where [DEVICEID] = @checkDevID and [ORDERID] = @orderID and [S_S] = 1000032/*pending*/

            exec [dbo].[PR_DEVICE_COMPLETED] @checkDevID, @orderID, @now, @userID /*KB2814*/
            exec [dbo].[PR_UPDATE_ORDERS] @checkDevID, null, null, null
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{f3a512e6-b20f-42c6-a31c-dc3ad366cc6e}}'
            return
          end
        end
      end

      if @ParentOperID is not null /*операция по troubleshooting */
      begin
        if (@DoneOperState in (1000013,1000019))
        begin
          declare @FreeRepair2 int
          declare @trMapType2 int
          declare @trMapID2 int
          declare @trMapN2 int
          declare @inQty int
          declare @troutQty int

          select
             @FreeRepair2 = isnull([opr].[FREETR],0)
            ,@trMapType2 = isnull([opr].[TRTYPE],0)
            ,@trMapID2 = [opr].[TRMAPID]
            ,@trMapN2 = isnull([opr].[TRMAP_N],0)
            ,@inQty = [opr].[Q_IN]
            ,@troutQty = [opr].[PREP_RESULT]
          from [dbo].[PR_OPERATION] [opr]
          where [opr].[ID] = @ParentOperID

          if @FreeRepair2 = 1
          begin
            goto ExitLabel
          end

          update [dbo].[PR_OPERATION_TODO] set [DONEID] = @DoneOperID where [OPERID] = @ParentOperID and [ID] = @todoId

          if @OperationSpecialType in (8,18) /*disassembly and recycling*/
          begin
            update [dbo].[PR_DEVICE] set [S_S] = 1000078 /* production failed */, [FAILED_DT] = @now where [ID] = @checkDevID 
            if (@orderType in (1,2)) /*service order*/
            begin
              update [dbo].[PR_DEVICE] set [S_S] = 1000158 /* recycled */ where [ID] = @checkDevID
            end
            delete from [dbo].[PR_OPERATION] where [DEVICEID] = @checkDevID and [ORDERID] = @orderID and [S_S] = 1000032/*pending*/

            exec [dbo].[PR_DEVICE_COMPLETED] @checkDevID, @orderID, @now, @userID /*KB2814*/
            exec [dbo].[PR_UPDATE_ORDERS] @checkDevID, null, null, null
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{8a36af8c-e154-419b-8e2d-4553a8af073b}}'
            return
          end

          /*KB1134*/
          if @OperationSpecialType = 13 /*item failed*/
          begin
            update [dbo].[PR_DEVICE] set [S_S] = 1000078 /* production failed */, [FAILED_DT] = @now where [ID] = @checkDevID
            delete from [dbo].[PR_OPERATION] where [DEVICEID] = @checkDevID and [ORDERID] = @orderID and [S_S] = 1000032/*pending*/
            exec [dbo].[PR_UPDATE_ORDERS] @checkDevID, null, null, null
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{535bb38a-4bec-4681-9891-7a87edaf6623}}'
            return
          end

          declare @ReturnFromTr int = 0

          if (@trMapType2 = 1) /*map*/
          begin
            begin try
              exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{7e86ab81-e030-436c-89ed-dc467ad36f95}}'
              exec [dbo].[PR_CREATE_NEXT4] @trMapID2,@DoneRevOper,@DoneLevel,@DoneOperID,@orderID,@DeviceID,null,@userID,@ParentOperID,@trMapN2,@inQty,@ScopeGroup=@ScopeGroup
              exec [trace].[SPTraceLeave] @ScopeName=N'{code:{10ba611d-ac40-4752-8a67-430c92560bee}}'
            end try
            begin catch
              exec [trace].[SPTraceLeave] @ScopeName=N'{code:{ae3cd858-2356-4557-8067-d40ee65f8f69}}';
              throw;
            end catch
            if [dbo].[PR_ALL_OP_DONE3](@trMapID2,@DeviceID,@orderID,@DoneLevel,@ParentOperID,@trMapN2) = 1
            begin
              set @ReturnFromTr = 1 /*больше операций нет - нужен возврат*/
            end
          end

          if (@trMapType2 = 0) /*classic*/
          begin
            declare @TrBranch int
            select @TrBranch = [A].[TRBRANCH] from [PR_OPERATION_TODO] [A] where [A].[OPERID] = @ParentOperID and [A].[ID] = @todoId

            declare @nextord2 int
            select
              @nextord2 = min([todo].[ORDERPOS])
            from [PR_OPERATION_TODO] [todo]
            where [todo].[OPERID] = @ParentOperID
              and isnull([todo].[TRBRANCH],-22) = isnull(@TrBranch,-22)
              and [todo].[DONEID] is null

            if @nextord2 is not null /* есть следующая операция*/
            begin
              --#region {43a1eeb4-c03b-47eb-9d40-124dfc252e61}
              delete from @NewOprT
              insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CDT],[S_CR],[PARENTID],[TODOID],[TODOTEXT],[USERINPROGRESS],[Q_IN])
              output inserted.ID into @NewOprT
                select
                   newid()
                  ,1000032
                  ,@orderID
                  ,@DeviceID
                  ,[todo].[OPERATIONID]
                  ,@now
                  ,@userID
                  ,@ParentOperID
                  ,[todo].[ID]
                  ,[todo].[TODO]
                  ,(select top 1 [user].[ID] from [DEF_USERS] [user] with(nolock) where [user].[EMPLOYEEID] = [todo].[EMPLOYEEID])
                  ,isnull(/*@troutQty 11.10.18*/@q_out_nullable,@inQty)
                from [dbo].[PR_OPERATION_TODO] [todo]
                where [todo].[OPERID] = @ParentOperID
                  and [todo].[ORDERPOS] = @nextord2
                  and isnull([todo].[TRBRANCH],-22) = isnull(@TrBranch,-22)
                  and not exists (select [oper].[ID]
                                  from [dbo].[PR_OPERATION] [oper]
                                  where [oper].[DEVICEID] = @DeviceID
                                    and [oper].[PARENTID] = @ParentOperID
                                    and [oper].[TODOID] = [todo].[ID]
                                    and [oper].[S_S] <> 1000023)

              insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
                select
                   getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
                  ,replace((select top 1
                     [o].*
                    ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                    ,'{43a1eeb4-c03b-47eb-9d40-124dfc252e61}' [DBG_CODE_LABEL]
                  from [dbo].[PR_OPERATION] [o]
                  where [o].[ID]=[a].[OPERID]
                  for json path),'\/','/')
                from @NewOprT [a]
              --#endregion

              if (@orderType in (1,2)) /*service order*/
              begin
                update [dbo].[PR_DEVICE]  set [S_S] = 1000011/*In Service*/ ,[SCOMPLETED_DT] = null where [ID] = @DeviceID and [S_S] = 1000039/*Service Completed*/
                update [dbo].[PR_PRORDER] set [S_S] = 1000035/*In Progress*/,[COMPLETED_DT]  = null where [ID] = @orderID  and [S_S] = 1000036/*Completed*/ 
              end
            end
            else
            begin
              /*перечитать наличие незавершенных без учета branch*/
              declare @existTrOper int = null
              select top 1
                @existTrOper = [todo].[ID]
              from [dbo].[PR_OPERATION_TODO] [todo]
              where [todo].[OPERID] = @ParentOperID
                and [todo].[DONEID] is null

              if @existTrOper is null
              begin
                set @ReturnFromTr = 1 /*больше операций нет - нужен возврат*/
              end
            end
          end

          if @ReturnFromTr = 1 /* возврат (один для classic и map)*/
          begin
            declare @returnTr int
            declare @BadOperID int /* операция с которой уходили в траблешутинг */
            select
               @returnTr = isnull([oper].[RETURNTR],0)
              ,@BadOperID = [oper].[PARENTID]
            from [dbo].[PR_OPERATION] [oper]
            where [oper].[ID] = @ParentOperID

            declare @doNotCloseServiceOrder int = 0  /*KB2727*/
            if @returnTr = 1
            begin
              update [dbo].[PR_OPERATION] set
                 [S_S] = 1000032
                ,[COMPLETED_DT] = null/*, RETURNTR = 0*/ /*11.10.2018*/
                ,[Q_IN] = isnull(@q_out_nullable,[Q_IN])
                ,[PREP_RESULT] = null
              where [ID] = @ParentOperID
            end
            else
            begin
              --commented out to continue map also for service orders
              --if @orderType = 0
              --begin
              /*возврат в производство*/
              if @BadOperID is not null
              begin
                declare @NewOperId int
                set @doNotCloseServiceOrder = 1

                --#region {f41bc463-c0fd-4639-8673-20eb7d5274bc}
                delete from @NewOprT
                insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CDT]
                    ,[REVOPERID],[RETURNAFTERTROUBLEID],[OPLEVEL],[OPERGR],[USERINTRAINING],[USERINPROGRESS],[Q_IN])
                output inserted.ID into @NewOprT
                  select
                     newid()                 [GID]
                    ,1000032                 [S_S]
                    ,@OrdID                  [ORDERID]
                    ,@DeviceID               [DEVICEID]
                    ,[oper].[OPERTYPEID]     [OPERTYPEID]
                    ,@now                    [S_CDT]
                    ,[oper].[REVOPERID]      [REVOPERID]
                    ,@ParentOperID           [RETURNAFTERTROUBLEID]
                    ,[oper].[OPLEVEL]        [OPLEVEL]
                    ,[oper].[OPERGR]         [OPERGR]
                    ,[oper].[USERINTRAINING] [USERINTRAINING]
                    ,case isnull([oprG].[VISTYPE],0) when 0 then null else [oper].[REPORTEDERRORUSER] end [USERINPROGRESS]
                    ,isnull(@q_out_nullable,[oper].[Q_IN]) [Q_IN]
                  from [dbo].[PR_OPERATION] [oper]
                    left join [dbo].[PR_OPERATIONS]    [oprF] on [oprF].[ID] = [oper].[OPERTYPEID]
                    left join [dbo].[PR_OPERATIONS_GR] [oprG] on [oprG].[ID] = [oprF].[OPERGRID]
                  where [oper].[ID] = @BadOperID
                    and not exists (select [o].[ID]
                                    from [dbo].[PR_OPERATION] [o]
                                    where [o].[DEVICEID] = @DeviceID
                                      and [o].[RETURNAFTERTROUBLEID] = @ParentOperID
                                      and [o].[S_S] <> 1000023);
                --#endregion

                set @NewOperId=SCOPE_IDENTITY();

                insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
                  select
                     getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
                    ,replace((select top 1
                         [o].*
                        ,@BadOperID    [@BadOperID]
                        ,@ParentOperID [@ParentOperID]
                        ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                        ,'{f41bc463-c0fd-4639-8673-20eb7d5274bc}' [DBG_CODE_LABEL]
                      from [dbo].[PR_OPERATION] [o]
                      where [o].[ID]=[a].[OPERID]
                      for json path),'\/','/')
                  from @NewOprT [a]

                --#AZURE04928: Transfers the [TODOTEXT] field from the operation that caused the "troubleshooting" operation to the repeated operation after the repair is completed.
                update [oper] set
                  [oper].[TODOTEXT]=[oprI].[TODOTEXT]
                from [dbo].[PR_OPERATION] [oper]
                  inner join @NewOprT [oprN] on [oprN].[OPERID]=[oper].[ID]
                  left  join [dbo].[PR_OPERATION] [oprP] with (nolock) on [oprP].[ID]=[oper].[RETURNAFTERTROUBLEID]
                  left  join [dbo].[PR_OPERATION] [oprI] with (nolock) on [oprI].[ID]=[oprP].[PARENTID]

                update [dbo].[COM_TRAINING_OPERATIONS] set
                  [TRAINING_STATE]=4
                where [OPERID]=@BadOperID

                insert into [COM_TRAINING_OPERATIONS] ([GID], [S_CDT], [S_CR], [DEVICE_ID], [MAPOPER_ID], [MODELID],
                                                          [OPERID], [REVISIONID], [TRAINER_ID], [TRAININGID])
                  select newid(), @now, @userID, [DEVICE_ID], [MAPOPER_ID], [MODELID], @NewOperId, [REVISIONID], [TRAINER_ID], [TRAININGID]
                  from [dbo].[COM_TRAINING_OPERATIONS] [O]
                  where [O].[OPERID]=@BadOperID

                update [dbo].[PR_OPERATION] set [TROUBLEEXIT] = 1 where [ID] = @BadOperID;
              end
              else
              begin
                /* вариант, когда troubleshooting был заложен в карте */
                if @orderType = 0 or (select [A].[REVOPERID] from [PR_OPERATION] [A] with(nolock) where [A].[ID] = @ParentOperID) is not null
                begin
                  select
                     @DoneOperID = [oper].[ID]  /* подмена на параметры самого траблшутинга - как будто завершается он*/
                    ,@DoneOperType = [oper].[OPERTYPEID]
                    ,@DoneRevOper = [oper].[REVOPERID]
                    ,@lastUserInProgress = isnull([oper].[LASTUSERINPROGRESS],[oper].[USERINPROGRESS])
                    ,@DoneLevel = isnull([oper].[OPLEVEL],0)
                    ,@OrdID=@orderID
                  from [dbo].[PR_OPERATION] [oper] with(nolock)
                  where [oper].[ID] = @ParentOperID;

                  goto BackLabel
                end
              end
              --end
              if (@orderType in (1,2)) /*service order*/ and @doNotCloseServiceOrder <> 1
              begin
                exec [dbo].[PR_DEVICE_COMPLETED] @DeviceID, @orderID ,@now ,@userID
              end
            end
          end
        end

        if (@DoneOperState in (1000018))
        begin
          if @repReasonEmtpy = 1
          begin
            exec [trace].[SPTraceEvent] @Message=N'Please set failure description.',@ScopeName=N'{code:{66f0dfb0-6709-4811-8b48-1c4a9c8bce97}}'
            raiserror('Please set failure description.[L=pr_set_failure_desc',15,0);
            return
          end

          update [dbo].[PR_OPERATION_TODO] set [DONEID] = @DoneOperID where [OPERID] = @ParentOperID and [ID] = @todoId

          /*новый FAR*/
          --declare @fr2ID int
          --set @fr2ID = null
        
          --if (@orderType = 0) /*производ. заказ*/
          --begin
              --insert into FC_REPORT (GID,S_S,S_CR,S_CDT,MODELID,SN,DEVICEID,FAILUREDESCRIPTION,FAILUREDATE,FROMDEPID,INT_EXT,REQUESTEDACTIONS,QUANTITY,TOTROUBLEID)
              --select NEWID(),1,A.S_MR,@now,B.MODELID,B.SN,B.ID,A.REPAIRREASON,cast (@now as DATE),OG.DEPARTMENTID,3,2,1,@ParentOperID
              --from PR_OPERATION A 
              --left join PR_DEVICE B on B.ID = A.DEVICEID
              --left join PR_OPERATIONS O on O.ID = A.OPERTYPEID
              --left join PR_OPERATIONS_GR OG on OG.ID = O.OPERGRID
              --where A.ID = @DoneOperID;
              --set @fr2ID = @@IDENTITY
          --end

          --update PR_OPERATION set S_S = 1000038, COMPLETED_DT = @now, FAILUREREPORTID = @fr2ID where ID = @DoneOperID
        
          /*возобновление troubleshooting*/
          --update PR_OPERATION set S_S = 1000032, COMPLETED_DT = null where ID = @ParentOperID
        end

        if @DoneOperState = 1000038 /*send to repair*/
        begin
          if @repReasonEmtpy = 1
          begin
            exec [trace].[SPTraceEvent] @Message=N'Please set failure description.',@ScopeName=N'{code:{3275710b-feb9-47d0-ade3-1072c9e3e2a7}}'
            raiserror('Please set failure description.[L=pr_set_failure_desc',15,0);
          end

          declare @fr2ID int
          set @fr2ID = @existingFRID

          if [dbo].[DEF_SYS_CONST_INT]('fr_disable_autocreation',0) <> 1
          begin
            if (@existingFRID is null and @orderType = 0) /*производ. заказ*/
            begin
              insert into [dbo].[FC_REPORT] ([GID],[S_S],[S_CR],[S_CDT],[MODELID],[SN],[DEVICEID],[FAILUREDESCRIPTION],[FAILUREDATE],[FROMDEPID],[INT_EXT],[REQUESTEDACTIONS],[QUANTITY],[TOTROUBLEID])
                select
                   NEWID()
                  ,1
                  ,[opr].[S_MR]
                  ,@now
                  ,[dev].[MODELID]
                  ,[dev].[SN]
                  ,[dev].[ID]
                  ,[opr].[REPAIRREASON]
                  ,cast (@now as DATE)
                  ,[opG].[DEPARTMENTID]
                  ,3
                  ,2
                  ,1
                  ,@ParentOperID
                from [dbo].[PR_OPERATION] [opr]
                  left join [dbo].[PR_DEVICE]        [dev] on [dev].[ID] = [opr].[DEVICEID]
                  left join [dbo].[PR_OPERATIONS]    [opF] on [opF].[ID] = [opr].[OPERTYPEID]
                  left join [dbo].[PR_OPERATIONS_GR] [opG] on [opG].[ID] = [opF].[OPERGRID]
                where [opr].[ID] = @DoneOperID;
              set @fr2ID = @@IDENTITY
            end
          end

          update [dbo].[PR_OPERATION] set [S_S] = 1000038, [COMPLETED_DT] = @now, [FAILUREREPORTID] = @fr2ID where [ID] = @DoneOperID
          update [dbo].[PR_OPERATION] set [S_S] = 1000032, [COMPLETED_DT] = null where [ID] = @ParentOperID
        end

        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{9ef538b1-3fcc-4804-9dff-58b462cabd8b}}'
        return
      end

      if @DoneOperState = 1000038  /*send to repair*/
      begin
        if @OperationSpecialType = 1
        begin
          exec [trace].[SPTraceEvent] @Message=N'Cannot set failure for troubleshooting operation.',@ScopeName=N'{code:{5620abe5-5365-4bc2-90bd-65da9cae1f3c}}'
          raiserror('Cannot set failure for troubleshooting operation.[L=pr_cannot_set_trouble',15,0);
        end

        if @repReasonEmtpy = 1
        begin
          exec [trace].[SPTraceEvent] @Message=N'Please set failure description.',@ScopeName=N'{code:{7103e3fd-77ed-4d77-82af-51c8d9a43fce}}'
          raiserror('Please set failure description.[L=pr_set_failure_desc',15,0);
        end

        declare @exID int
        select
          @exID = [oper].[ID]
        from [dbo].[PR_OPERATION] [oper] with(nolock)
        where [oper].[DEVICEID] = @DeviceID
          and [oper].[ORDERID] = @OrdID
          and [oper].[PARENTID] = @DoneOperState;

        if @exID is null /*нет troubleshooting по этой проблемной операции*/
        begin
          declare @TroubleTypeID int
          select top 1
            @TroubleTypeID = [oprF].[ID]
          from [dbo].[PR_OPERATIONS] [oprF] with(nolock)
          where [oprF].[MTID] = @ModTypeID
            and [oprF].[OPERTYPE] = 1
            and [oprF].[DEPID] = @ModelOwnerDepID

          if @TroubleTypeID is null
          begin
            select top 1
              @TroubleTypeID = [oprF].[ID]
            from [dbo].[PR_OPERATIONS] [oprF] with(nolock)
            where [oprF].[MTID] = @ModTypeID
              and [oprF].[OPERTYPE] = 1
          end

          if @TroubleTypeID is null
          begin
            declare @mtName nvarchar(200)
            select @mtName = [NAME] from [dbo].[PR_MODELTYPE] with(nolock) where [ID] = @ModTypeID;
            declare @errMsg nvarchar(250)
            set @errMsg = 'Troubleshooting operation not defined in model type "'+@mtName+'".';
            exec [trace].[SPTraceEvent] @Message=@errMsg,@ScopeName=N'{code:{ef1d204b-23a8-4f65-8d6a-bfdb01f4c6e9}}'
            raiserror(@errMsg,15,0); 
            return
          end

          declare @frID int
          declare @trID int
          set @frID = @frID0

          if isnull(@frID0,0) < 1
          begin
            if [dbo].[DEF_SYS_CONST_INT]('fr_disable_autocreation',0) <> 1
            begin
              insert into [dbo].[FC_REPORT] ([PARENTID],[GID],[S_S],[S_CR],[S_CDT],[MODELID],[SN],[DEVICEID],[FAILUREDESCRIPTION],[FAILUREDATE],[FROMDEPID],[INT_EXT],[REQUESTEDACTIONS],[QUANTITY])
                select
                   [dbo].[FC_FIND_PARENT_FAR]([opr].[ORDERID],[opr].[DEVICEID])
                  ,newid()
                  ,1
                  ,[opr].[S_MR]
                  ,@now
                  ,[dev].[MODELID]
                  ,[dev].[SN]
                  ,[dev].[ID]
                  ,[opr].[REPAIRREASON]
                  ,cast (@now as DATE)
                  ,[opG].[DEPARTMENTID]
                  ,3
                  ,2
                  ,1
                from [dbo].[PR_OPERATION] [opr]
                  left join [dbo].[PR_DEVICE]        [dev] on [dev].[ID] = [opr].[DEVICEID]
                  left join [dbo].[PR_OPERATIONS]    [opF] on [opF].[ID] = [opr].[OPERTYPEID]
                  left join [dbo].[PR_OPERATIONS_GR] [opG] on [opG].[ID] = [opF].[OPERGRID]
                where [opr].[ID] = @DoneOperID;

              set @frID = @@identity
            end
          end

          --#region {a7376e55-b784-4410-98aa-e692a9c8f1e4}
          delete from @NewOprT
          insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CR],[S_CDT],[PARENTID],[TODOTEXT],[SPECIALTYPE],[FAILUREREPORTID],[Q_IN])
          output inserted.ID into @NewOprT
            select
               newid()
              ,1000032
              ,@OrdID
              ,@DeviceID
              ,@TroubleTypeID
              ,[opr].[S_MR]
              ,@now
              ,[opr].[ID]
              ,[opr].[REPAIRREASON]
              ,1
              ,@frID
              ,[opr].[Q_IN]
            from [dbo].[PR_OPERATION] [opr]
            where [opr].[ID] = @DoneOperID;
          --#endregion

          set @trID = @@identity

          insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
            select
                getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
               ,replace((select top 1
                    [o].*
                   ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                   ,'{a7376e55-b784-4410-98aa-e692a9c8f1e4}' [DBG_CODE_LABEL]
                 from [dbo].[PR_OPERATION] [o]
                 where [o].[ID]=[a].[OPERID]
                 for json path),'\/','/')
            from @NewOprT [a]

          update [dbo].[FC_REPORT] set [TOTROUBLEID] = @trID where [ID] = @frID
        end

        update [dbo].[PR_OPERATION] set [COMPLETED_DT] = @now where [ID] = @DoneOperID
      end

      BackLabel:
      if @DoneOperState in (1000013,1000019)  /*Complete , Complete with Err*/
      begin
        if exists (select [auto].[ID]
                   from [dbo].[PR_AUTOPOSTPONE] [auto]
                   where [auto].[DEVICEID] = @DeviceID
                     and [auto].[MAPOPERID] = @DoneRevOper
                     and [auto].[S_S] = 1)
        begin
          update [dbo].[PR_DEVICE] set [S_S] = 1000069 where [ID] = @DeviceID
          update [dbo].[PR_AUTOPOSTPONE] set [S_S] = 1000126 /*Processed*/, [OPERID] = @DoneOperID where [DEVICEID] = @DeviceID and [MAPOPERID] = @DoneRevOper and [S_S] = 1
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{f616f0e5-59c2-4ac5-a7e1-3458a14d5b46}}'
          return
        end

        if exists (select [auto].[ID]
                   from [dbo].[PR_AUTOOPERATION] [auto]
                   where [auto].[DEVICEID] = @DeviceID
                     and [auto].[MAPOPERID] = @DoneRevOper
                     and [auto].[S_S] = 1)
        begin
          declare @operFormId int;
          declare @todoText nvarchar(max);
          select
             @operFormId=[auto].[OPERFORMID]
            ,@todoText=[auto].[DESCRIPTION]
          from [dbo].[PR_AUTOOPERATION] [auto]
          where [auto].[DEVICEID] = @DeviceID
            and [auto].[MAPOPERID] = @DoneRevOper
            and [auto].[S_S] = 1

          --#region {2bfec5a9-36f3-4a30-8f90-097166d6e136}
          delete from @NewOprT
          insert into [dbo].[PR_OPERATION] ([GID],[S_S],[ORDERID],[DEVICEID],[OPERTYPEID],[S_CDT],[S_CR],[TODOTEXT])
          output inserted.ID into @NewOprT
            values (newid(),1000032,@OrdID,@DeviceID,@operFormId,@now,@UserID,@todoText)
          --#endregion

          set @trID = scope_identity()

          update [dbo].[PR_AUTOOPERATION] set
             [S_S] = 1000126   /*Processed*/
            ,[BOUNDOPERID] = @DoneOperID 
            ,[OPERID] = @trID
          where [DEVICEID] = @DeviceID
            and [MAPOPERID] = @DoneRevOper
            and [S_S] = 1

          insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
            select
                getdate(),1,'Document created.',@UserID,20000,1000039,[a].[OPERID]
               ,replace((select top 1
                    [o].*
                   ,'a2l://doc/?ClassLabel=pr_device_operation&ID='+cast([o].[ID] as varchar(max)) "PDB_OPER_LINK"
                   ,'{2bfec5a9-36f3-4a30-8f90-097166d6e136}' [DBG_CODE_LABEL]
                 from [dbo].[PR_OPERATION] [o]
                 where [o].[ID]=[a].[OPERID]
                 for json path),'\/','/')
            from @NewOprT [a]

          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{0260a6d1-dc1b-4133-bafb-d6967adc5f17}}'
          return
        end

        if exists (select [auto].[ID]
                   from [dbo].[PR_AUTOOPERATION] [auto]
                   where [auto].[DEVICEID] = @DeviceID
                     and [auto].[OPERID] = @DoneOperID
                     and [auto].[S_S] = 1000126  /*Processed*/)
        begin
          declare @boundOperId int = (select [auto].[BOUNDOPERID]
                                      from [dbo].[PR_AUTOOPERATION] [auto]
                                      where [auto].[DEVICEID] = @DeviceID
                                        and [auto].[OPERID] = @DoneOperID
                                        and [auto].[S_S] = 1000126  /*Processed*/)

          begin try
            exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{00cc649b-7460-456d-8016-4d902ba11e4e}}'
            exec [dbo].[PR_NEXT_OPERATION4] @DeviceID,@boundOperId,@ScopeGroup=@ScopeGroup;
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{2533cdc5-961a-4e1d-a87a-a9b76cee12e6}}'
          end try
          begin catch
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{d364232d-0214-460c-a7fc-b4b2b2af5f18}}';
            throw;
          end catch

          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{0b2e7f1b-9b45-482e-b8da-d7b833ce2cca}}'
          return
        end

        declare @AllDone int
        set @AllDone = 0

        begin try
          exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{491b3160-18f2-4d7c-ae6f-6910afa18251}}'
          exec [dbo].[PR_CREATE_NEXT4] @MapID,@DoneRevOper,@DoneLevel,@DoneOperID,@OrdID,@DeviceID,@lastUserInProgress,@userID,null,null,@RestQty,@ScopeGroup=@ScopeGroup
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{7e87e8fe-7f73-4fde-8694-28a2560d2114}}'
        end try
        begin catch
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{adea93d1-7caa-4394-b164-7d06d0708d16}}';
          throw;
        end catch

        if @BlockCompl = 0
        begin
          set @AllDone = [dbo].[PR_ALL_OP_DONE3](@MapID,@DeviceID,@OrdID,@DoneLevel,null,null)
        end

        if (@AllDone = 1)  /* все готово */
        begin
          exec [dbo].[PR_DEVICE_COMPLETED] @DeviceID, @OrdID ,@now ,@userID, @DoneOperID /* DEVOPS:6195 */
        end
        else if @orderType = 0 
        begin
          exec [dbo].[PR_UPDATE_PRTIME] @DeviceID  /*проставлять оставшееся время только по производственному заказу*/
          exec [dbo].[CP_UPDATE_TICKET] @ModTypeID, @DeviceID , @userID /*потенциальные тикеты тоже*/
        end

        exec [dbo].[PR_CHECK_DOC_BYOPERATIONS] @DoneOperID, @userID  /* заполнения списка Declarations of Conformity */
      end

      --training
      --если завершена, проставить в обучении "завершено"
      if @DoneOperState in (1000013)
      begin
        begin try
          exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{6943af92-f3c8-4dc1-a7b8-0cbfd993401d}}'
          exec [dbo].[COM_SET_TRAINING_COMPLETE] @DoneOperID, @userID,@ScopeGroup=@ScopeGroup
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{8a5f7846-0e74-4871-b44e-22a09ed12858}}'
        end try
        begin catch
          exec [trace].[SPTraceLeave] @ScopeName=N'{code:{5b9dde9c-9311-4030-9210-388de839c5e8}}';
          throw;
        end catch
      end
    end
    ExitLabel:
      exec [trace].[SPTraceLeave] @ScopeName=N'{code:{633cb30c-5e7a-44cc-a3f8-d30261bfc59b}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[PR_NEXT_OPERATION4]'   [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{93dba9c9-4132-480d-8ba7-10200a406c0b}}';
    throw;
  end catch
  set nocount off