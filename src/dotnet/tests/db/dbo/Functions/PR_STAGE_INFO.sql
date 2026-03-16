CREATE function [dbo].[PR_STAGE_INFO](@DeviceID int, @OrderID int , @StageID int, @aBeg datetime, @aEnd datetime, @aMode int)
returns decimal(10,4) as 
begin
  /*
  @aMode 
  1 - возвращает:
           1 если участок завершен в заданный период; 
           2 если участок изменен в заданный период
  2 - возвращает дельту % (за период) готовности участка
  3 - возвращает % готовности участка
  4 - возвращает сумму норм времени для всех операций участка
  5 - возвращает 1 если на какой-нибудь операции участка нет нормы
  6 - возвращает сумму норм времени для выполненных за период операций участка
  7 - возвращает сумму норм времени для выполненных по @aEnd операций участка
  8 - возвращает сумму времен (но не больше нормы) по недоделанным операциям участка выполненных за период 
  9 - возвращает сумму времен (но не больше нормы) по недоделанным операциям участка выполненных по @aEnd 
  12- возвращает дельту % (за период) готовности участка (оценка по кол-ву, когда нормы некорректны)
  13- возвращает % готовности участка (оценка по кол-ву, когда нормы некорректны)
  14 - возвращает количество операций участка
  16 - возвращает количество операций участка выполненных за период 
  17 - возвращает количество операций участка выполненных по @aEnd
  */
  declare @res decimal(10,4)

  if @aMode = 1
  begin
    /*
     если не существует НАЧАТЫХ операций по этому участку - участок не пройден вообще
    */
    if not exists (select [opr].[ID]
                   from [dbo].[PR_OPERATION] [opr] with(nolock)
                     inner join [dbo].[PR_OPERATION_TIME] [opt] with(nolock) on [opr].[ID]=[opt].[OPERID]
                     left  join [dbo].[PR_OPERATIONS]     [opf] with(nolock) on [opf].[ID]=[opr].[OPERTYPEID]
                    where [opr].[DEVICEID] = @DeviceID
                      and [opr].[ORDERID] = @OrderID
                      and [opr].[REVOPERID] is not null
                      and [opf].[STAGEID] = @StageID
                      and [opt].[DBEG] < @aEnd)
     and not exists (select [opr].[ID]
                     from [dbo].[PR_OPERATION] [opr] with(nolock)
                       inner join [dbo].[PR_OPERATION_TIME] [opt] with(nolock) on [opt].[OPERID]=[opr].[ID]
                       left  join [dbo].[PR_OPERATIONS]     [ofr] with(nolock) on [ofr].[ID]=[opr].[OPERTYPEID]
                       left  join [dbo].[PR_DEVICE]         [dev] with(nolock) on [dev].[ID]=[opr].[DEVICEID]
                    where [dev].[PARENTID] = @DeviceID
                      and [opr].[ORDERID] = @OrderID
                      and [opr].[REVOPERID] is not null
                      and [ofr].[STAGEID] = @StageID
                      and [opt].[DBEG] < @aEnd)
    begin
      return 0;
    end

     /*
      если существует незакрытая операция или операция, закрытая позже, или незакрытый ремонт
      то участок не завершен, но "продвинут" за заданный период
     */
    if exists (select [opr].[ID]
               from [dbo].[PR_OPERATION] [opr] with(nolock)
                 left join [dbo].[PR_OPERATIONS] [opf] with(nolock) on [opf].[ID]=[opr].[OPERTYPEID]
               where [opr].[DEVICEID] = @DeviceID
                 and [opr].[ORDERID] = @OrderID
                 and [opr].[REVOPERID] is not null
                 and ([opr].[COMPLETED_DT] is null or [opr].[COMPLETED_DT] > @aEnd or ([opr].[S_S] = 1000038 and isnull([opr].[TROUBLEEXIT],0) = 0))
                 and [opf].[STAGEID] = @StageID)
            or exists (select [opr].[ID]
                       from [dbo].[PR_OPERATION] [opr] with(nolock)
                         left join [dbo].[PR_OPERATIONS] [opf] with(nolock) on [opf].[ID]=[opr].[OPERTYPEID]
                         left join [dbo].[PR_DEVICE]     [dev] with(nolock) on [dev].[ID]=[opr].[DEVICEID]
                       where [dev].[PARENTID] = @DeviceID
                         and [opr].[ORDERID] = @OrderID
                         and [opr].[REVOPERID] is not null
                         and ([opr].[COMPLETED_DT] is null or [opr].[COMPLETED_DT] > @aEnd or ([opr].[S_S] = 1000038 and isnull([opr].[TROUBLEEXIT],0) = 0))
                         and [opf].[STAGEID] = @StageID)
    begin
      return 2
    end

    /* если максимальная дата завершения всех непропущенных операций стадии попадает в период, то участок завершен в этот период*/
    declare @maxCompl datetime
    /*
    select @maxCompl = MAX(A.COMPLETED_DT)
    from PR_OPERATION A with (nolock) 
      left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID 
    where A.DEVICEID = @DeviceID
      and A.ORDERID = @OrderID
      and A.REVOPERID is not null
      and B.STAGEID = @StageID
    */
    select @maxCompl = max(isnull([opr].[COMPLETED_DT],'40000101'))
    from [dbo].[PR_DEVICE] [dev] with(nolock)
      left join [dbo].[PR_MAP_OPER]   [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
      left join [dbo].[PR_OPERATIONS] [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
      left join [dbo].[PR_OPERATION]  [opr] with(nolock) on [opr].[DEVICEID]=[dev].[ID] and [opr].[ORDERID]=@OrderID and [opr].[REVOPERID]=[map].[ID]
     where [dev].[ID] = @DeviceID
       and [opf].[STAGEID] = @StageID
       and not exists (select [ski].[DEVICEID]
                       from [dbo].[PR_DEVICE_SKIPPED_OP] [ski] with(nolock)
                       where [ski].[DEVICEID]=[dev].[ID]
                         and [ski].[ORDERID]=@OrderID
                         and [ski].[REVOPERID]=[map].[ID])

    if @maxCompl >= @aBeg and @maxCompl < @aEnd
    begin
      return 1
    end

     if exists (select [opr].[ID]
                from [dbo].[PR_OPERATION] [opr] with(nolock)
                  inner join [dbo].[PR_OPERATION_TIME] [opt] with(nolock) on [opt].[OPERID]=[opr].[ID]
                  left  join [dbo].[PR_OPERATIONS]     [opf] with(nolock) on [opf].[ID]=[opr].[OPERTYPEID]
                where [opr].[DEVICEID] = @DeviceID
                  and [opr].[ORDERID] = @OrderID
                  and [opr].[REVOPERID] is not null
                  and [opf].[STAGEID] = @StageID
                  and [opt].[DBEG] < @aEnd 
                  and isnull([opt].[DEND],'40000101') > @aBeg
            )
    or exists (select [opr].[ID]
               from [dbo].[PR_OPERATION] [opr] with(nolock)
                 inner join [dbo].[PR_OPERATION_TIME] [opt] with(nolock) on [opt].[OPERID]=[opr].[ID]
                 left  join [dbo].[PR_OPERATIONS]     [opf] with(nolock) on [opf].[ID]=[opr].[OPERTYPEID]
                 left  join [dbo].[PR_DEVICE]         [dev] with(nolock) on [dev].[ID]=[opr].[DEVICEID]
               where [dev].[PARENTID] = @DeviceID
                 and [opr].[ORDERID] = @OrderID
                 and [opr].[REVOPERID] is not null
                 and [opf].[STAGEID] = @StageID
                 and [opt].[DBEG] < @aEnd
                 and isnull([opt].[DEND],'40000101') > @aBeg
            )
    begin
      return 2
    end

    /*return null  18.08.2017 */
    return null
  end
  else if @aMode = 2
  begin
    /* 2 - возвращает дельту % (за период) готовности участка*/

    declare @allStageTime decimal(10,4) /*сумма норм времени по всем операциям стадии*/
    declare @deltaStageTime decimal(10,4) /*сумма норм времени по завершенным за указанный период операций, относящихся к стадии*/
    declare @deltaStageAdd decimal(10,4) /*сумма времени затраченного по НЕзавершенным за указанный период операций, относящихся к стадии*/

    set @allStageTime   = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,4)
    set @deltaStageTime = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,6)
    set @deltaStageAdd  = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,8)

    if @allStageTime > 0
      set @res = ((ISNULL(@deltaStageTime,0) + isnull(@deltaStageAdd,0)) / @allStageTime) * 100

     return @res
  end
  else if @aMode = 3
  begin
    /* 3 - возвращает % готовности участка*/
    declare @allStageTime2 decimal(10,4) /*сумма норм времени по всем операциям стадии*/
    declare @cmplStageTime decimal(10,4) /*сумма норм времени по завершенным до @dEnd операций, относящихся к стадии*/
    declare @cmplStageAdd  decimal(10,4) /*сумма времени затраченного по НЕзавершенным до @dEnd операций, относящихся к стадии*/

    set @allStageTime2 = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,4)
    set @cmplStageTime = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,7)
    set @cmplStageAdd  = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,8)

    if @allStageTime2 > 0
    begin
      set @res = ((ISNULL(@cmplStageTime,0) + isnull(@cmplStageAdd,0)) / @allStageTime2) * 100
    end
    return @res
  end
  else if @aMode = 4
  begin
    /* 4 - возвращает сумму норм времени для всех операций участка */
    select @res = sum(coalesce([omh].[MANHOUR2],[opf].[MANHOUR]) * coalesce([mul].[MULTIPLI],[map].[MULTIPLI],1.0))
    from [dbo].[PR_DEVICE] [dev] with(nolock)
      left join [dbo].[PR_MAP_OPER]          [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
      left join [dbo].[PR_OPERATIONS]        [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
      left join [dbo].[PR_REV_OVER_MH]       [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
      left join [dbo].[PR_REV_OVER_MULTIPLI] [mul] with(nolock) on [mul].[REVID]=[dev].[REVID] and [mul].[MAPOPERID]=[map].[ID]
    where [dev].[ID] = @DeviceID
      and [opf].[STAGEID] = @StageID
      and [dbo].[PR_OPER_ISACTIVE_4DEVICE]([dev].[ID],[map].[ID],[map].[CONDITION],0) = 1
    return @res
  end 
  else if @aMode = 5
  begin
     /* 5 - возвращает 1 если на какой-нибудь операции участка нет нормы */
     if exists (
       select [dev].[ID]
       from [dbo].[PR_DEVICE] [dev] with(nolock)
         left join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
         left join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
         left join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
       where [dev].[ID] = @DeviceID
         and [opf].[STAGEID] = @StageID
         and [dbo].[PR_OPER_ISACTIVE_4DEVICE]([dev].[ID],[map].[ID],[map].[CONDITION],0) = 1
         and coalesce([omh].[MANHOUR2],[opf].[MANHOUR]) is null
         )
     return 1
  end 
  else if @aMode = 6
  begin
    /* 6 - возвращает сумму норм времени для выполненных за период операций участка */
    select @res = SUM(coalesce([omh].[MANHOUR2],[opf].[MANHOUR]))
    from [dbo].[PR_DEVICE] [dev] with(nolock)
      left join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
      left join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
      left join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
    where [dev].[ID] = @DeviceID
      and [opf].[STAGEID] = @StageID
      and exists (select [opr].[ID]
                  from [dbo].[PR_OPERATION] [opr] with(nolock)
                  where [opr].[DEVICEID] = @DeviceID
                    and [opr].[ORDERID] = @OrderID
                    and [opr].[COMPLETED_DT] is not null
                    and [opr].[COMPLETED_DT] between @aBeg and @aEnd
                    and [opr].[REVOPERID] = [map].[ID]
                    )

    select @res = @res + isnull([dbo].[PR_STAGE_INFO]([dev].[ID],@OrderID,@StageID,@aBeg,@aEnd,@aMode),0)
    from [dbo].[PR_DEVICE] [dev] with(nolock)
    where [dev].[PARENTID] = @DeviceID

    return @res
  end 
  else if @aMode = 7
  begin
    /* 7 - возвращает сумму норм времени для выполненных по @aEnd операций участка */
    select @res = sum(coalesce([omh].[MANHOUR2],[opf].[MANHOUR]))
    from [dbo].[PR_DEVICE] [dev] with(nolock)
      left join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID] = [dev].[MAPID]
      left join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID] = [map].[OPERID]
      left join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID] = [dev].[REVID] and [omh].[OPERID] = [opf].[ID]
    where [dev].[ID] = @DeviceID
      and [opf].[STAGEID] = @StageID
      and exists (select [opr].[ID]
                  from [dbo].[PR_OPERATION] [opr] with(nolock)
                  where [opr].[DEVICEID] = @DeviceID
                    and [opr].[ORDERID] = @OrderID
                    and [opr].[COMPLETED_DT] is not null
                    and [opr].[COMPLETED_DT] < @aEnd
                    and [opr].[REVOPERID] = [map].[ID]
                    )

     select @res = @res + isnull([dbo].[PR_STAGE_INFO]([dev].[ID],@OrderID,@StageID,@aBeg,@aEnd,@aMode),0)
     from [dbo].[PR_DEVICE] [dev] with(nolock)
     where [dev].[PARENTID] = @DeviceID

     return @res
  end
  else if @aMode = 8
  begin
    /* 8 - возвращает сумму времен (но не больше нормы) по недоделанным операциям участка выполненных за период */
    declare @addT decimal(10,4);
    with [M2] as
      (
      /*select dbo.PR_WORKTIME2BETWEEN(B.ID,GETDATE(),@aBeg,@aEnd) as WT*/
      select (select sum([dbo].[PR_WORKTIME2BETWEEN]([opt].[ID],getdate(),@aBeg,@aEnd))
              from [dbo].[PR_OPERATION_TIME] [opt] with(nolock)
              where [opt].[OPERID] = [opr].[ID]
                and [opt].[DBEG] < @aEnd 
                and ([opt].[DEND] is null or [opt].[DEND] > @aBeg)
              ) as [WT]
            ,coalesce([omh].[MANHOUR2],[opf].[MANHOUR]) as [NORM]
      from [dbo].[PR_DEVICE] [dev] with(nolock)
        left join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
        left join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
        left join [dbo].[PR_OPERATION]   [opr] with(nolock) on [opr].[DEVICEID]=[dev].[ID] and [opr].[OPERTYPEID]=[map].[OPERID]
        left join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
        /*left join [dbo].[PR_OPERATION_TIME] [B] on [B].[OPERID] = [J].[ID]*/
      where [dev].[ID] = @DeviceID
        and [opf].[STAGEID] = @StageID
        and [opr].[ORDERID] = @OrderID
        and ([opr].[COMPLETED_DT] is null or [opr].[COMPLETED_DT] > @aEnd)
        /*and B.DBEG < @aEnd
        and (B.DEND is null or B.DEND > @aBeg)*/
      ),
      [M3] as
        (
        select case when [M2].[WT] > [M2].[NORM] then [M2].[NORM] else [M2].[WT] end as [RES]
        from [M2] [M2]
        )
    select @addT = sum([M3].[RES])
    from [M3] [M3]

    select @addT = @addT + isnull([dbo].[PR_STAGE_INFO]([dev].[ID],@OrderID,@StageID,@aBeg,@aEnd,@aMode),0)
    from [dbo].[PR_DEVICE] [dev] with(nolock)
    where [dev].[PARENTID] = @DeviceID

    return @addT
  end
  else if @aMode = 9
  begin
     /* 9 - возвращает сумму времен (но не больше нормы) по недоделанным операциям участка выполненных по @aEnd  */
    declare @addT2 decimal(10,4);
    with [M2] as
      (
      /*select dbo.PR_WORKTIME2BETWEEN(B.ID,GETDATE(),B.DBEG,@aEnd) as WT*/
      select (select sum([dbo].[PR_WORKTIME2BETWEEN]([opt].[ID],getdate(),@aBeg,@aEnd))
              from [dbo].[PR_OPERATION_TIME] [opt] with(nolock)
              where [opt].[OPERID]=[opr].[ID]
                and [opt].[DBEG] < @aEnd 
                and ([opt].[DEND] is null or [opt].[DEND] > @aBeg)
              ) as [WT]
            , coalesce([omh].[MANHOUR2],[opf].[MANHOUR]) as [NORM]
      from [dbo].[PR_DEVICE] [dev] with(nolock)
        left join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
        left join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
        left join [dbo].[PR_OPERATION]   [opr] with(nolock) on [opr].[DEVICEID]=[dev].[ID] and [opr].[OPERTYPEID]=[map].[OPERID]
        left join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
        /*left join PR_OPERATION_TIME B on B.OPERID = J.ID*/
      where [dev].[ID] = @DeviceID
        and [opf].[STAGEID] = @StageID
        and [opr].[ORDERID] = @OrderID
        and ([opr].[COMPLETED_DT] is null or [opr].[COMPLETED_DT] > @aEnd)
        /*and B.DBEG < @aEnd
        and (B.DEND is null or B.DEND > @aBeg)*/
      ), [M3] as
      (
      select
        case when [M2].[WT] > [M2].[NORM] then [M2].[NORM] else [M2].[WT] end as [RES]
      from [M2] [M2]
      )
    select @addT2 = sum([M3].[RES])
    from [M3] [M3]

    select @addT2 = @addT2 + isnull([dbo].[PR_STAGE_INFO]([dev].[ID],@OrderID,@StageID,@aBeg,@aEnd,@aMode),0)
    from [dbo].[PR_DEVICE] [dev] with(nolock)
    where [dev].[PARENTID] = @DeviceID

    return @addT2
  end
  else if @aMode = 12
  begin
    declare @allStageQty decimal(10,4) /*количество операций стадии*/
    declare @deltaStageQty decimal(10,4) /*количество операций стадии завершенных за указанный период*/

    set @allStageQty   = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,14)
    set @deltaStageQty = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,16)

    if @allStageQty > 0
      set @res = (@deltaStageQty / @allStageQty) * 100

    return @res
  end
  else if @aMode = 13
  begin
    declare @allStageQty2 decimal(10,4) /*количество операций стадии*/
    declare @cmplStageQty decimal(10,4) /*количество операций стадии завершенных до @dEnd */

    set @allStageQty2 = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,14)
    set @cmplStageQty = [dbo].[PR_STAGE_INFO](@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,17)

    if @allStageQty2 > 0
      set @res = (@cmplStageQty / @allStageQty2) * 100

    return @res
  end
  else if @aMode = 14
  begin
    select @res = count(*)
    from [dbo].[PR_DEVICE] [dev] with(nolock)
      left join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
      left join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
      left join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
    where [dev].[ID] = @DeviceID
      and [opf].[STAGEID] = @StageID
      and [dbo].[PR_OPER_ISACTIVE_4DEVICE]([dev].[ID],[map].[ID],[map].[CONDITION],0) = 1

    select @res = @res + isnull([dbo].[PR_STAGE_INFO]([dev].[ID],@OrderID,@StageID,@aBeg,@aEnd,@aMode),0)
    from [dbo].[PR_DEVICE] [dev] with(nolock)
    where [dev].[PARENTID] = @DeviceID

    return @res
  end 
  else if @aMode = 16
  begin
    select @res = count(*)
    from [dbo].[PR_DEVICE] [dev] with(nolock)
      left join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
      left join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
      left join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
    where [dev].[ID] = @DeviceID
      and [opf].[STAGEID] = @StageID
      and exists (select [opr].[ID]
                  from [dbo].[PR_OPERATION] [opr] with(nolock)
                  where [opr].[DEVICEID] = @DeviceID
                    and [opr].[ORDERID] = @OrderID
                    and [opr].[COMPLETED_DT] is not null
                    and [opr].[COMPLETED_DT] between @aBeg and @aEnd
                    and [opr].[REVOPERID] = [map].[ID]
                    )

    select @res = @res + isnull([dbo].[PR_STAGE_INFO]([dev].[ID],@OrderID,@StageID,@aBeg,@aEnd,@aMode),0)
    from [dbo].[PR_DEVICE] [dev] with(nolock)
    where [dev].[PARENTID] = @DeviceID

    return @res
  end 
  else if @aMode = 17
  begin
    select @res = COUNT(*)
    from [dbo].[PR_DEVICE] [dev] with(nolock)
      left join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
      left join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
      left join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
    where [dev].[ID] = @DeviceID
      and [opf].[STAGEID] = @StageID
      and exists (select [opr].[ID]
                  from [dbo].[PR_OPERATION] [opr] with(nolock)
                  where [opr].[DEVICEID] = @DeviceID
                    and [opr].[ORDERID] = @OrderID
                    and [opr].[COMPLETED_DT] is not null
                    and [opr].[COMPLETED_DT] < @aEnd
                    and [opr].[REVOPERID] = [map].[ID]
                    )

    select @res = @res + isnull([dbo].[PR_STAGE_INFO]([dev].[ID],@OrderID,@StageID,@aBeg,@aEnd,@aMode),0)
    from [dbo].[PR_DEVICE] [dev] with(nolock)
    where [dev].[PARENTID] = @DeviceID

    return @res
  end
  return null;

end