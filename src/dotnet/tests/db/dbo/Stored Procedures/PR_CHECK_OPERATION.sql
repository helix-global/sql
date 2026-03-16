CREATE procedure [dbo].[PR_CHECK_OPERATION] @OperID int, @aMode int, @aUserID int 
as
  set nocount on

  declare @DoneOpts int
  declare @PrepResult int
  declare @NoInputOperation int
  declare @BlockLimit int
  declare @BlockLimitLow int
  declare @checkKB4546 int

  select
     @DoneOpts = [oper].[DONEOPT]
    ,@PrepResult = isnull([oper].[PREP_RESULT],0)
    ,@NoInputOperation = isnull([oprF].[FORMXML_NOI],0)
    ,@BlockLimit = isnull([mapO].[BLOCKCMPLLIMIT],0)
    ,@BlockLimitLow = isnull([mapO].[BLOCKCMPLLOW],0)
    ,@checkKB4546 = isnull([oprF].[CHECKKB4546],0)
  from [dbo].[PR_OPERATION] [oper] with(nolock)
    left join [dbo].[PR_OPERATIONS] [oprF] with(nolock) on [oprF].[ID] = [oper].[OPERTYPEID]
    left join [dbo].[PR_MAP_OPER]   [mapO] with(nolock) on [mapO].[ID] = [oper].[REVOPERID]
  where [oper].[ID] = @OperID

  if @NoInputOperation <> 1
  begin
    /* checkpoints */
    if not (substring(reverse(@DoneOpts),1,1) = '1')
    begin
      raiserror('Unable to complete operation while not all control points checked.[L=pr_not_all_checkpoints',15,0)
    end

    /* проверка полноты установленных SN второй с конца разряд*/
    if not (substring(reverse(@DoneOpts),2,1) = '1')
    begin
      raiserror('Please set all required components serial numbers.[L=pr_pl_set_all_req_sn',15,0);
    end

    /*
      Operation Check Required Values
      10xx - проверялось но отрицательно
      11xx - проверялось и все ОК
      xx - не проверялось (старый клиент)
    */
    if (substring(reverse(@DoneOpts),3,2) = '01')
    begin
      raiserror('Please set all required values.[L=pr_pl_set_all_req_val',15,0);
    end

    /*
      Checks Conditions
      10xxxx - проверялось но отрицательно
      11xxxx - проверялось и все ОК
        xxxx или xx - не проверялось (старый клиент)
    */
    if (substring(reverse(@DoneOpts),5,2) = '01')
    begin
      print '@DoneOpts='+isnull(format(@DoneOpts,'d'),'null')
      raiserror('Operation contains invalid values.[L=pr_oper_contains_errors',15,0);
    end
  end

  if exists (select *
             from [dbo].[PR_OPERATION_MU] [opMU] with(nolock)
             where [opMU].[OPERID] = @OperID
               and [opMU].[QUANTITY] is null)
  begin
    raiserror('Please fill in quantity of the materials used.[L=pr_oper_empty_mu',15,0);
  end

  if exists (select *
             from [dbo].[PR_OPERATION_MU] [opMU] with(nolock)
             where [opMU].[OPERID] = @OperID
               and [dbo].[PR_VALID_PARTNUMBER]([opMU].[CODE]) = 0)
  begin
    raiserror('Invalid part numbers used in materials table.[L=pr_oper_invalid_pn_mu',15,0);
  end

  if @PrepResult < 0
  begin
    raiserror('Invalid preparatory operation result.[L=pr_invalid_prep_result',15,0);
  end

  if @checkKB4546 = 1
  begin
    if exists (select *
               from [dbo].[PR_OPERATION_MU] [opMU] with(nolock)
               where [opMU].[OPERID] = @OperID
                 and isnull([opMU].[QTYPEROPERATION],0) <> 1)
    begin
      raiserror('Quantity per Operation should be "Yes" in materials usage table.[L=pr_oper_err_kb4546',15,0);
    end
  end

  declare @errEqSN nvarchar(100)
  select top 1
    @errEqSN = [equi].[SN]
  from [dbo].[PR_OPERATION_PARAMS] [oprP] with(nolock)
    left join [dbo].[EQ_EQUIPMENT] [equi] with(nolock) on [equi].[ID] = [oprP].[EQID]
  where [oprP].[OPERID] = @OperID
    and [oprP].[EQID] is not null
    and exists (select [oper].[ID]
                from [dbo].[PR_OPERATION] [oper] with(nolock)
                where [oper].[EQID] = [oprP].[EQID]
                  and [oper].[COMPLETED_DT] is null
                  and [oper].[S_S] <> 1000023 /*canceled*/
                  and [oper].[S_S] <> 1000038 /*f.processed*//*KB4479*/)

  if @errEqSN is not null
  begin
    declare @errmsg nvarchar(500)
    set @errmsg = 'Equipment item "'+@errEqSN+'" contains unfinished maintenance operations. Unable to complete operation where used such equipment.'
    set @errmsg = @errmsg +N'[RU=Оборудование "'+@errEqSN+'" содержит незавершенные операции обслуживания. Невозможно завершить операцию в которой используется такое оборудование.'
    raiserror(@errmsg,15,0);
  end

  if [dbo].[PR_REQUIRED_REPORTS_PRINTED](@OperID)=0
  begin
    raiserror(N'Not all required reports printed[RU=Не все требуемые отчеты отправлены на печать.',15,0);
  end

  if @BlockLimit > 0  /*KB2673*/ or @BlockLimitLow > 0 /*KB2874*/
  begin
    if [dbo].[DEF_USERINGROUP5](@aUserID,'SPV','DES','ADM',null,null) = 0
    begin
      declare @norm decimal(18,4)
      declare @normHi decimal(18,4)
      declare @normLow decimal(18,4)
      declare @fact decimal(18,4)

      set @norm = [dbo].[PR_OPER_TIME_NORM](@OperID)

      if @norm > 0
      begin
        select
          @fact = sum(coalesce([A].[ELAPSED_D],[A].[ELAPSED],[dbo].[PR_WORKTIME5]([ID],isnull([DEND],getdate()))))
        from [dbo].[PR_OPERATION_TIME] [A] with(nolock)
        where [A].[OPERID] = @OperID

        set @normHi = @norm + (@norm/100*@BlockLimit)
        set @normLow = @norm - (@norm/100*@BlockLimitLow)

        if @BlockLimit > 0 and @fact > @normHi
        begin
          declare @errMess nvarchar(max)
          set @errMess = 'Operation time exceeded the time norm value * '+cast(@BlockLimit as nvarchar(20))+'%%. Please contact supervisor.'
          set @errMess = @errMess +'[RU=Время операции превысило норму времени * '+cast(@BlockLimit as nvarchar(20))+'%%. Пожалуйста обратитесь к супервизору.'
          raiserror(@errMess,15,0);
        end
        if @BlockLimitLow > 0 and @fact < @normLow
        begin
          declare @errMess2 nvarchar(max)
          set @errMess2 = 'Operation time below the time norm value * '+cast(@BlockLimitLow as nvarchar(20))+'%%. Please contact supervisor.'
          set @errMess2 = @errMess2 +'[RU=Время операции меньше нормы времени за вычетом '+cast(@BlockLimitLow as nvarchar(20))+'%%. Пожалуйста обратитесь к супервизору.'
          raiserror(@errMess2,15,0);
        end
      end
    end
  end
  set nocount off