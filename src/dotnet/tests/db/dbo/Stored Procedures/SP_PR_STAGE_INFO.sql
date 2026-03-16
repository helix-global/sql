
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-03-20
-- Description: Builds stage calc info spread-sheet.
-- =============================================
-- KB5302:2025-03-18: Initial Update.
-- KB5341:2025-03-32: Fixed period issue. Disabled [PR_OPER_ISACTIVE_4DEVICE] function simulation use [PR_OPER_ISACTIVE_4DEVICE] instead.
CREATE procedure [dbo].[SP_PR_STAGE_INFO] @DevP [dbo].[Int32TableTypeU] readonly,@StgP [dbo].[Int32TableTypeU] readonly,@Beg date,@End date,@Options nvarchar(max)
with recompile
as
begin
  set nocount on
  declare @DT datetime
  declare @RecordCount int = 0
  declare
    @OutT table
     (
     [DEVID] int
    ,[ORDID] int
    ,[STGID] int
    ,[MOD01] decimal(10,4) -- 1 если участок завершен в заданный период;2 если участок изменен в заданный период
    ,[MOD02] decimal(10,4) -- дельта % (за период) готовности участка
    ,[MOD03] decimal(10,4) -- % готовности участка
    ,[MOD04] decimal(10,4) -- сумма норм времени для всех операций участка
    ,[MOD05] decimal(10,4) -- 1 если на какой-нибудь операции участка нет нормы
    ,[MOD06] decimal(10,4) -- сумма норм времени для выполненных за период операций участка
    ,[MOD07] decimal(10,4) -- сумма норм времени для выполненных по @End операций участка
    ,[MOD08] decimal(10,4) -- сумма времен (но не больше нормы) по недоделанным операциям участка выполненных за период
    ,[MOD09] decimal(10,4) -- сумма времен (но не больше нормы) по недоделанным операциям участка выполненных по @End
    ,[MOD12] decimal(10,4) -- дельта % (за период) готовности участка (оценка по кол-ву, когда нормы некорректны)
    ,[MOD13] decimal(10,4) -- % готовности участка (оценка по кол-ву, когда нормы некорректны)
    ,[MOD14] decimal(10,4) -- количество операций участка
    ,[MOD16] decimal(10,4) -- количество операций участка выполненных за период
    ,[MOD17] decimal(10,4) -- количество операций участка выполненных по @End
    primary key clustered ([DEVID],[ORDID],[STGID])
    )

  declare @OptionsT table([OPTION] nvarchar(max))
  insert into @OptionsT
    select [a].[OPTION]
    from [dbo].[COM_OPT_SPLIT](@Options) [a]

  declare @ExcludeModesOption nvarchar(max)=null
  select top 1
    @ExcludeModesOption=right([o].[OPTION],len([o].[OPTION])-13)
  from @OptionsT [o]
  where [o].[OPTION] like N'ExcludeModes=%'

  declare @ExcludeModesT table([MODE] int primary key clustered)
  insert into @ExcludeModesT
    select distinct
      cast([a].[VALUE] as int)
    from [dbo].[COM_STR_SPLIT](@ExcludeModesOption,null,null) [a]

  declare @ModeRange table([MODE] int primary key clustered,[DBEG] date,[DEND] date,[ENABLED] int,index [MODE-ENABLED]([MODE],[ENABLED]))
  insert into @ModeRange
    select  1,@Beg,@End,1 union all
    select  2,@Beg,@End,1 union all
    select  3,@Beg,@End,1 union all
    select  4,@Beg,@End,1 union all
    select  5,@Beg,@End,1 union all
    select  6,@Beg,@End,1 union all
    select  7,@Beg,@End,1 union all
    select  8,@Beg,@End,1 union all
    select  9,@Beg,@End,1 union all
    select 12,@Beg,@End,1 union all
    select 13,@Beg,@End,1 union all
    select 14,@Beg,@End,1 union all
    select 16,@Beg,@End,1 union all
    select 17,@Beg,@End,1

  if exists(select * from @ExcludeModesT)
  begin
    update [a] set
      [a].[ENABLED]=0
    from @ModeRange [a]
      inner join @ExcludeModesT [b] on [b].[MODE]=[a].[MODE]
  end

  set @DT = getdate()
  declare @DevT table ([DEVID] int,[ORDID] int primary key clustered ([DEVID],[ORDID]))
  insert into @DevT
    select
      [dev].[ID]
      ,[dev].[ORDERID]
    from @DevP [a]
      inner join [dbo].[PR_DEVICE] [dev] with(nolock) on [dev].[ID]=[a].[ID]
    where [dev].[ORDERID] is not null
  select @RecordCount=count(*) from @DevT
  print '{'+format(getdate(),'o')+ '}:build{@DevT}           :{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}:'+format(@RecordCount,'d5')

  set @DT = getdate()
  declare @StgT table([STGID] int,[STAGE] nvarchar(255),[STAGE_ORDER] int primary key clustered ([STGID],[STAGE],[STAGE_ORDER]))
  insert into @StgT([STGID],[STAGE],[STAGE_ORDER])
    select
       [s].[ID] [STAGE_ID]
      ,[s].[NAME] [STAGE]
      ,isnull([s].[ORDERPOS],0) [STAGE_ORDER]
    from @StgP [a]
      inner join [PR_STAGES] [s] with(nolock) on [s].[ID]=[a].[ID]
  select @RecordCount=count(*) from @StgT
  print '{'+format(getdate(),'o')+ '}:build{@StgT}           :{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}:'+format(@RecordCount,'d5')

  set @DT = getdate()
  declare @DevStgT table([DEVID] int,[ORDID] int,[STGID] int
    ,index [DEVID-STGID]([DEVID],[STGID])
    ,index [DEVID]([DEVID])
    ,index [STGID]([STGID])
    ,index [ORDID-STGID]([ORDID],[STGID])
    ,primary key clustered ([DEVID],[ORDID],[STGID]))
  insert into @DevStgT
    select
       [a].[DEVID]
      ,[a].[ORDID]
      ,[b].[STGID]
    from @DevT [a]
      cross join @StgT [b]
  select @RecordCount=count(*) from @StgT
  print '{'+format(getdate(),'o')+ '}:build{@DevStgT}        :{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}:'+format(@RecordCount,'d5')

  insert into @OutT([DEVID],[ORDID],[STGID])
    select
       [a].[DEVID]
      ,[a].[ORDID]
      ,[a].[STGID]
    from @DevStgT [a]

  set @DT = getdate()
  declare @OprT table([OPERID] int primary key clustered,[DEVID] int,[ORDID] int,[STGID] int,[OPFID] int,[COMPLETED_DT] datetime,[REVOPERID] int
    ,index [DEVID-ORDID-STGID-OPFID]([DEVID],[ORDID],[STGID],[OPFID]))
  insert into @OprT
    select
       [opr].[ID]
      ,[a].[DEVID]
      ,[a].[ORDID]
      ,[a].[STGID]
      ,[opf].[ID]
      ,[opr].[COMPLETED_DT]
      ,[opr].[REVOPERID]
    from @DevStgT [a]
      inner join [dbo].[PR_OPERATIONS] [opf] with(nolock) on [opf].[STAGEID]=[a].[STGID]
      inner join [dbo].[PR_OPERATION]  [opr] with(nolock) on [opr].[ORDERID]=[a].[ORDID] and [opr].[OPERTYPEID]=[opf].[ID]
      inner join [dbo].[PR_DEVICE]     [dev] with(nolock) on [dev].[ID]=[opr].[DEVICEID]
    where [opr].[REVOPERID] is not null
      and ([dev].[ID]=[a].[DEVID] or [dev].[PARENTID]=[a].[DEVID])
  select @RecordCount=count(*) from @OprT
  print '{'+format(getdate(),'o')+ '}:build{@OprT}           :{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}:'+format(@RecordCount,'d5')

  set @DT = getdate()
  declare @DevMapT table([DEVID] int,[MAPID] int,[REVID] int,[RMHID] int,[OPFID] int,[STGID] int,[ORDID] int,[MANHOUR] decimal(10,4)
    ,index [MAPID]([MAPID])
    ,index [DEVID-MAPID-MANHOUR]([DEVID],[MAPID],[MANHOUR])
    ,index [DEVID-STGID] clustered ([DEVID],[STGID]))
  insert into @DevMapT
    select distinct
       [dev].[ID]
      ,[map].[ID]
      ,[dev].[REVID]
      ,[omh].[ID]
      ,[opf].[ID]
      ,[a].[STGID]
      ,[a].[ORDID]
      ,coalesce([omh].[MANHOUR2],[opf].[MANHOUR])
    from @DevStgT [a]
      inner join [dbo].[PR_DEVICE]      [dev] with(nolock) on [dev].[ID]=[a].[DEVID]
      inner join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
      inner join [dbo].[PR_OPERATIONS]  [opf] with(nolock,index([IX_PR_OPERATIONS_ID_STAGEID])) on [opf].[ID]=[map].[OPERID]
      left  join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[OPERID]=[opf].[ID] and [omh].[REVID]=[dev].[REVID]
    where [opf].[STAGEID]=[a].[STGID]

  declare @DevMapS table([DEVID] int,[MAPID] int,primary key clustered ([DEVID],[MAPID]))
  insert into @DevMapS
    select distinct
       [a].[DEVID]
      ,[a].[MAPID]
    from @DevMapT [a]

  declare @DevMapI table([DEVID] int,[MAPID] int,[PR_OPER_ISACTIVE_4DEVICE] int,[CONDITION] int,primary key clustered ([DEVID],[MAPID]))
  /*insert into @DevMapI
    select distinct
       [a].[DEVID]
      ,[a].[MAPID]
      ,1
      ,isnull([map].[CONDITION],0)
    from @DevMapS [a]
      inner join [dbo].[PR_MAP_OPER] [map] with(nolock) on [map].[ID]=[a].[MAPID]
    where isnull([map].[CONDITION],0) in (0,7)

  ;with
    [PR_MAP_OPER] as
    (
    select
       [a].[DEVID]
      ,[a].[MAPID]
      ,[map].[CONDITION]
      ,[par].[PARAMKIND]
      ,[dbo].[PR_DEVICE_PARAM]([a].[DEVID],[map].[C_PARAMID]) [PARAMVALUE]
      ,[map].[C_ACT] [ACTION]
    from @DevMapS [a]
      inner join [dbo].[PR_MAP_OPER]         [map] with(nolock) on [map].[ID]=[a].[MAPID]
      left  join [dbo].[PR_MODELTYPE_PARAMS] [par] with(nolock) on [par].[ID]=[map].[C_PARAMID]
    where [map].[CONDITION] in (1)
    )
  insert into @DevMapI
    select distinct
       [a].[DEVID]
      ,[a].[MAPID]
      ,case when [a].[PARAMKIND]=2 and [a].[ACTION]=2 and isnull([dbo].[DEF_VARIANT2BOOL]([a].[PARAMVALUE]),0) <> 1 then 0
            when [a].[PARAMKIND]=2 and [a].[ACTION]=3 and isnull([dbo].[DEF_VARIANT2BOOL]([a].[PARAMVALUE]),0) = 1  then 0
            else
              [dbo].[PR_FLOW_OR_OPER_ALLOWED](null,[a].[MAPID],[a].[DEVID])
            end
      ,[a].[CONDITION]
    from [PR_MAP_OPER] [a]
    option (maxdop 8)

  insert into @DevMapI
    select distinct
       [a].[DEVID]
      ,[a].[MAPID]
      ,[dbo].[PR_FLOW_OR_OPER_ALLOWED](null,[a].[MAPID],[a].[DEVID])
      ,isnull([map].[CONDITION],0)
    from @DevMapS [a]
      inner join [dbo].[PR_MAP_OPER] [map] with(nolock) on [map].[ID]=[a].[MAPID]
    where isnull([map].[CONDITION],0) not in (0,1,7)
    option (maxdop 8)*/

  insert into @DevMapI
    select distinct
       [a].[DEVID]
      ,[a].[MAPID]
      ,[dbo].[PR_OPER_ISACTIVE_4DEVICE]([a].[DEVID],[map].[ID],[map].[CONDITION],0)
      ,[map].[CONDITION]
    from @DevMapS [a]
      inner join [dbo].[PR_MAP_OPER] [map] with(nolock) on [map].[ID]=[a].[MAPID]

  delete from [a]
  from @DevMapT [a]
    inner join @DevMapI [b] on [b].[DEVID]=[a].[DEVID] and [b].[MAPID]=[a].[MAPID]
  where [b].[PR_OPER_ISACTIVE_4DEVICE]<>1
  select @RecordCount=count(*) from @DevMapT
  print '{'+format(getdate(),'o')+ '}:build{@DevMapT}        :{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}:'+format(@RecordCount,'d5')

  set @DT = getdate()
  declare @DevMapP table([DEVID] int,[MAPID] int,[REVID] int,[RMHID] int,[OPFID] int,[STGID] int,[ORDID] int,[MANHOUR] decimal(10,4)
    ,index [MAPID]([MAPID])
    ,index [DEVID-STGID] clustered ([DEVID],[STGID]))
  insert into @DevMapP
    select distinct
       [dev].[PARENTID]
      ,[map].[ID]
      ,[dev].[REVID]
      ,[omh].[ID]
      ,[opf].[ID]
      ,[a].[STGID]
      ,[a].[ORDID]
      ,coalesce([omh].[MANHOUR2],[opf].[MANHOUR])
    from @DevStgT [a]
      inner join [dbo].[PR_DEVICE]      [dev] with(nolock) on [dev].[PARENTID]=[a].[DEVID]
      left  join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
      left  join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
      left  join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
    where [opf].[STAGEID]=[a].[STGID]

  delete from @DevMapS
  insert into @DevMapS
    select distinct
       [a].[DEVID]
      ,[a].[MAPID]
    from @DevMapP [a]

  insert into @DevMapI
    select distinct
       [a].[DEVID]
      ,[a].[MAPID]
      ,[dbo].[PR_OPER_ISACTIVE_4DEVICE]([a].[DEVID],[map].[ID],[map].[CONDITION],0)
      ,[map].[CONDITION]
    from @DevMapS [a]
      inner join [dbo].[PR_MAP_OPER] [map] with(nolock) on [map].[ID]=[a].[MAPID]

  delete from [a]
  from @DevMapP [a]
    inner join @DevMapI [b] on [b].[DEVID]=[a].[DEVID] and [b].[MAPID]=[a].[MAPID]
  where [b].[PR_OPER_ISACTIVE_4DEVICE]<>1
  select @RecordCount=count(*) from @DevMapP
  print '{'+format(getdate(),'o')+ '}:build{@DevMapP}        :{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}:'+format(@RecordCount,'d5')

  --#region calc{01}
  if exists(select * from @ModeRange [a] where [a].[MODE]=1 and [a].[ENABLED]=1)
  begin
    set @DT = getdate()
    -- Если не существует НАЧАТЫХ операций по этому участку - участок не пройден вообще
    update [a] set
      [a].[MOD01]=0
    from @OutT [a]
    where [a].[MOD01] is null
      and not exists(select *
                     from @OprT [b]
                       inner join [dbo].[PR_OPERATION_TIME] [opt] with(nolock) on [opt].[OPERID]=[b].[OPERID]
                     where ([a].[DEVID]=[b].[DEVID] and [a].[ORDID]=[b].[ORDID] and [a].[STGID]=[b].[STGID])
                       and (cast([opt].[DBEG] as date) < @End))

    -- если существует незакрытая операция или операция, закрытая позже, или незакрытый ремонт
    -- то участок не завершен, но "продвинут" за заданный период
    update [a] set
      [a].[MOD01]=2
    from @OutT [a]
    where [a].[MOD01] is null
      and exists(select *
                 from @OprT [b]
                   inner join [dbo].[PR_OPERATION] [opr] with(nolock) on [opr].[ID]=[b].[OPERID]
                 where ([a].[DEVID]=[b].[DEVID] and [a].[ORDID]=[b].[ORDID] and [a].[STGID]=[b].[STGID])
                   and ([opr].[COMPLETED_DT] is null
                   or (cast([opr].[COMPLETED_DT] as date) > @End)
                   or ([opr].[S_S] = 1000038 and isnull([opr].[TROUBLEEXIT],0) = 0)))

    -- если максимальная дата завершения всех непропущенных операций стадии попадает в период, то участок завершен в этот период
    ;with [T] as
      (
      select
         [a].[DEVID]
        ,[a].[ORDID]
        ,[a].[STGID]
        ,max(isnull([opr].[COMPLETED_DT],'40000101')) [MAXCMPLDT]
      from @OutT [a]
        inner join [dbo].[PR_DEVICE]     [dev] with(nolock) on [dev].[ID]=[a].[DEVID]
        left  join [dbo].[PR_MAP_OPER]   [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
        left  join [dbo].[PR_OPERATIONS] [opf] with(nolock) on [opf].[ID]=[map].[OPERID]
        left  join [dbo].[PR_OPERATION]  [opr] with(nolock) on [opr].[DEVICEID]=[dev].[ID] and [opr].[ORDERID]=[a].[ORDID] and [opr].[REVOPERID]=[map].[ID]
      where [dev].[ID]=[a].[DEVID]
        and [opf].[STAGEID]=[a].[STGID]
        and not exists (select [ski].[DEVICEID]
                        from [dbo].[PR_DEVICE_SKIPPED_OP] [ski] with(nolock)
                        where [ski].[DEVICEID]=[dev].[ID]
                          and [ski].[ORDERID]=[a].[ORDID]
                          and [ski].[REVOPERID]=[map].[ID])
      group by [a].[DEVID],[a].[ORDID],[a].[STGID]
      )
    update [a] set
      [a].[MOD01]=1
    from @OutT [a]
      inner join [T] [b] on [a].[DEVID]=[b].[DEVID] and [a].[ORDID]=[b].[ORDID] and [a].[STGID]=[b].[STGID]
      inner join @ModeRange [r] on [r].[MODE]=1
    where [a].[MOD01] is null
      and [b].[MAXCMPLDT] >= [r].[DBEG] and [b].[MAXCMPLDT] < [r].[DEND]

    update [a] set
      [a].[MOD01]=2
    from @OutT [a]
    where [a].[MOD01] is null
      and exists(select *
                 from @OprT [b]
                   inner join [dbo].[PR_OPERATION_TIME] [opt] with(nolock) on [opt].[OPERID]=[b].[OPERID]
                   inner join @ModeRange [r] on [r].[MODE]=1
                 where ([a].[DEVID]=[b].[DEVID] and [a].[ORDID]=[b].[ORDID] and [a].[STGID]=[b].[STGID])
                   and (cast([opt].[DBEG] as date) < [r].[DEND])
                   and (isnull([opt].[DEND],'40000101') > [r].[DBEG]))
    print '{'+format(getdate(),'o')+ '}:calc{01}:{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}'
  end
  --#endregion

  declare @DevMapU table([DEVID] int,[MAPID] int,[REVID] int,[RMHID] int,[OPFID] int,[STGID] int,[ORDID] int,[MANHOUR] decimal(10,4)
    ,index [DEVID-STGID] clustered ([DEVID],[STGID])
    ,index [DEVID-STGID-OPFID]([DEVID],[STGID],[OPFID])
    ,index [DEVID-STGID-MANHOUR]([DEVID],[STGID],[MANHOUR]))
  insert into @DevMapU
    select * from @DevMapP union all
    select * from @DevMapT

  --select * from @DevMapU

  --#region calc{04}
  if exists(select * from @ModeRange [a] where [a].[MODE]=4 and [a].[ENABLED]=1)
  begin
    /*select * from @DevMapT [b]
    select sum([b].[MANHOUR]*coalesce([mul].[MULTIPLI],[map].[MULTIPLI],1.0))
    from @DevMapT [b]
      inner join @OutT [a] on [b].[DEVID]=[a].[DEVID] and [b].[STGID]=[a].[STGID]
      left  join [dbo].[PR_MAP_OPER]          [map] with(nolock) on [map].[ID]=[b].[MAPID]
      left  join [dbo].[PR_REV_OVER_MULTIPLI] [mul] with(nolock) on [mul].[REVID]=[b].[REVID] and [mul].[MAPOPERID]=[b].[MAPID]
    where [b].[MANHOUR] is not null

    select count(*)
    from @DevMapT [b]
      inner join @OutT [a] on [b].[DEVID]=[a].[DEVID] and [b].[STGID]=[a].[STGID]
      left  join [dbo].[PR_MAP_OPER]          [map] with(nolock) on [map].[ID]=[b].[MAPID]
      left  join [dbo].[PR_REV_OVER_MULTIPLI] [mul] with(nolock) on [mul].[REVID]=[b].[REVID] and [mul].[MAPOPERID]=[b].[MAPID]
    where [b].[MANHOUR] is not null
    */
    set @DT = getdate()
    update [a] set
      [a].[MOD04]=(select sum([b].[MANHOUR]*coalesce([mul].[MULTIPLI],[map].[MULTIPLI],1.0))
                   from @DevMapT [b]
                     left join [dbo].[PR_MAP_OPER]          [map] with(nolock) on [map].[ID]=[b].[MAPID]
                     left join [dbo].[PR_REV_OVER_MULTIPLI] [mul] with(nolock) on [mul].[REVID]=[b].[REVID] and [mul].[MAPOPERID]=[b].[MAPID]
                    where [b].[DEVID]=[a].[DEVID]
                      and [b].[STGID]=[a].[STGID]
                      and [b].[MANHOUR] is not null)
    from @OutT [a]
    print '{'+format(getdate(),'o')+ '}:calc{04}:{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}'
  end
  --#endregion
  --#region calc{05}
  if exists(select * from @ModeRange [a] where [a].[MODE]=5 and [a].[ENABLED]=1)
  begin
    set @DT = getdate()
    update [a] set
      [a].[MOD05]=case when exists(select *
                                   from @DevMapT [b]
                                   where [b].[DEVID]=[a].[DEVID]
                                     and [b].[STGID]=[a].[STGID]
                                     and [b].[ORDID]=[a].[ORDID]
                                     and [b].[MANHOUR] is null) then 1 else null end
    from @OutT [a]
    print '{'+format(getdate(),'o')+ '}:calc{05}:{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}'
  end
  --#endregion
  --#region calc{06}
  if exists(select * from @ModeRange [a] where [a].[MODE]=6 and [a].[ENABLED]=1)
  begin
    set @DT = getdate()
    update [a] set
       [a].[MOD06]=(select sum([b].[MANHOUR])
                    from @DevMapU [b]
                    where [b].[DEVID]=[a].[DEVID] and [b].[STGID]=[a].[STGID]
                      and [b].[MANHOUR] is not null
                      and exists (select *
                                  from @OprT [o]
                                    inner join @ModeRange [r] on [r].[MODE]=6
                                  where [o].[COMPLETED_DT] is not null
                                    and cast([o].[COMPLETED_DT] as date)>=[r].[DBEG]
                                    and cast([o].[COMPLETED_DT] as date)<=[r].[DEND]
                                    and [o].[REVOPERID]=[b].[MAPID]
                                    and [o].[DEVID]=[b].[DEVID]
                                    ))
    from @OutT [a]
    print '{'+format(getdate(),'o')+ '}:calc{06}:{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}'
  end
  --#endregion
  --#region calc{07}
  if exists(select * from @ModeRange [a] where [a].[MODE]=7 and [a].[ENABLED]=1)
  begin
    set @DT = getdate()
    update [a] set
       [a].[MOD07]=(select sum([b].[MANHOUR])
                    from @DevMapU [b]
                    where [b].[DEVID]=[a].[DEVID] and [b].[STGID]=[a].[STGID]
                      and [b].[MANHOUR] is not null
                      and exists (select *
                                  from @OprT [o]
                                    inner join @ModeRange [r] on [r].[MODE]=7
                                  where [o].[COMPLETED_DT] is not null
                                    and cast([o].[COMPLETED_DT] as date) <= [r].[DEND]
                                    and [o].[REVOPERID]=[b].[MAPID]
                                    and [o].[DEVID]=[b].[DEVID]
                                    ))
    from @OutT [a]
    print '{'+format(getdate(),'o')+ '}:calc{07}:{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}'
  end
  --#endregion
  --#region calc{14}
  if exists(select * from @ModeRange [a] where [a].[MODE]=14 and [a].[ENABLED]=1)
  begin
    set @DT = getdate()
    update [a] set
       [a].[MOD14]=(select count(*)
                    from @DevMapU [b]
                    where [b].[DEVID]=[a].[DEVID] and [b].[STGID]=[a].[STGID]
                      and [b].[OPFID] is not null)
    from @OutT [a]
    print '{'+format(getdate(),'o')+ '}:calc{14}:{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}'
  end
  --#endregion
  --#region calc{16}
  if exists(select * from @ModeRange [a] where [a].[MODE]=16 and [a].[ENABLED]=1)
  begin
    set @DT = getdate()
    update [a] set
       [a].[MOD16]=(select count(*)
                    from @DevMapU [b]
                    where [b].[DEVID]=[a].[DEVID] and [b].[STGID]=[a].[STGID]
                      and [b].[OPFID] is not null
                      and exists (select *
                                  from @OprT [o]
                                    inner join @ModeRange [r] on [r].[MODE]=16
                                  where [o].[COMPLETED_DT] is not null
                                    and cast([o].[COMPLETED_DT] as date)>=[r].[DBEG]
                                    and cast([o].[COMPLETED_DT] as date)<=[r].[DEND]
                                    and [o].[REVOPERID]=[b].[MAPID]
                                    and [o].[DEVID]=[b].[DEVID]
                                    ))
    from @OutT [a]
    print '{'+format(getdate(),'o')+ '}:calc{16}:{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}'
  end
  --#endregion
  --#region calc{16}
  if exists(select * from @ModeRange [a] where [a].[MODE]=17 and [a].[ENABLED]=1)
  begin
    set @DT = getdate()
    update [a] set
       [a].[MOD17]=(select count(*)
                    from @DevMapU [b]
                    where [b].[DEVID]=[a].[DEVID] and [b].[STGID]=[a].[STGID]
                      and [b].[OPFID] is not null
                      and exists (select *
                                  from @OprT [o]
                                    inner join @ModeRange [r] on [r].[MODE]=17
                                  where [o].[COMPLETED_DT] is not null
                                    and cast([o].[COMPLETED_DT] as date)<=[r].[DEND]
                                    and [o].[REVOPERID]=[b].[MAPID]
                                    and [o].[DEVID]=[b].[DEVID]
                                    ))
    from @OutT [a]
    print '{'+format(getdate(),'o')+ '}:calc{17}:{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}'
  end
  --#endregion
  --#region calc{08}
  if exists(select * from @ModeRange [a] where [a].[MODE]=8 and [a].[ENABLED]=1)
  begin
    set @DT = getdate()
    declare @OprW table([OPERID] int primary key clustered,[PR_WORKTIME2BETWEEN] int);
    with [OPR] as
      (
      select
         [opr].[OPERID] [OPERID]
        ,[opr].[DEVID]
        ,[opr].[ORDID]
        ,[opr].[STGID]
        ,[opr].[OPFID]
      from @OprT [opr]
        inner join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[opr].[OPFID]
        inner join @ModeRange [r] on [r].[MODE]=8
      where ([opr].[COMPLETED_DT] is null or cast([opr].[COMPLETED_DT] as date)>[r].[DEND])
      )
      insert into @OprW
        select
           [opr].[OPERID]
          ,sum([dbo].[PR_WORKTIME2BETWEEN]([opt].[ID],getdate(),[r].[DBEG],[r].[DEND])) [PR_WORKTIME2BETWEEN]
        from [OPR] [opr]
          left join [dbo].[PR_OPERATION_TIME] [opt] with(nolock) on [opt].[OPERID]=[opr].[OPERID]
          inner join @ModeRange [r] on [r].[MODE]=8
        where cast([opt].[DBEG] as date) <= [r].[DEND]
          and ([opt].[DEND] is null or [opt].[DEND] > [r].[DBEG])
        group by [opr].[OPERID]

    ;with
    [OPRB] as
      (
      select
         [a].[OPERID]
        ,[o].[DEVID]
        ,[o].[ORDID]
        ,[o].[STGID]
        ,[opf].[ID] [OPFID]
        ,[map].[ID] [MAPID]
        ,[omh].[ID] [OMHID]
        ,[a].[PR_WORKTIME2BETWEEN]
        ,coalesce([omh].[MANHOUR2],[opf].[MANHOUR]) as [MANHOUR]
      from @OprW [a]
        inner join @OprT [o] on [o].[OPERID]=[a].[OPERID]
        inner join [dbo].[PR_OPERATION]   [opr] with(nolock) on [opr].[ID]=[o].[OPERID]
        inner join [dbo].[PR_DEVICE]      [dev] with(nolock) on [dev].[ID]=[o].[DEVID]
        left  join [dbo].[PR_MAP_OPER]    [map] with(nolock) on [map].[MAPID]=[dev].[MAPID]
        left  join [dbo].[PR_OPERATIONS]  [opf] with(nolock) on [opf].[ID]=[map].[OPERID] and [opf].[ID]=[opr].[OPERTYPEID]
        left  join [dbo].[PR_REV_OVER_MH] [omh] with(nolock) on [omh].[REVID]=[dev].[REVID] and [omh].[OPERID]=[opf].[ID]
      where [opf].[STAGEID]=[o].[STGID]
      ),
    [OPRF] as
      (
      select
         [a].[OPERID]
        ,[a].[DEVID]
        ,[a].[ORDID]
        ,[a].[STGID]
        ,[a].[OPFID]
        ,[a].[MAPID]
        ,[a].[OMHID]
        ,case when [a].[PR_WORKTIME2BETWEEN] > [a].[MANHOUR] then [a].[MANHOUR] else [a].[PR_WORKTIME2BETWEEN] end [MANHOUR]
      from [OPRB] [a]
      ),
    [OPRG] as
      (
      select
         [a].[DEVID]
        ,[a].[ORDID]
        ,[a].[STGID]
        ,sum([a].[MANHOUR]) [MANHOUR]
      from [OPRF] [a]
      group by
         [a].[DEVID]
        ,[a].[ORDID]
        ,[a].[STGID]
      )
    update [a] set
      [a].[MOD08]=[b].[MANHOUR]
    from @OutT [a]
      inner join [OPRG] [b] on [b].[DEVID]=[a].[DEVID] and [b].[ORDID]=[a].[ORDID] and [b].[STGID]=[a].[STGID]
    print '{'+format(getdate(),'o')+ '}:calc{08}:{'+format(datediff(ms,@DT,getdate())/1000.0,'00000.00')+N'sec.}'
  end
  --#endregion

  update [a] set
     [a].[MOD09]=[a].[MOD08]
    ,[a].[MOD02]=case when [a].[MOD04]>0 then ((isnull([a].[MOD06],0) + isnull([a].[MOD08],0))/[a].[MOD04])* 100 else null end
    ,[a].[MOD03]=case when [a].[MOD04]>0 then ((isnull([a].[MOD07],0) + isnull([a].[MOD08],0))/[a].[MOD04])* 100 else null end
    ,[a].[MOD12]=case when [a].[MOD14]>0 then ([a].[MOD16]/[a].[MOD14]) * 100 else null end
    ,[a].[MOD13]=case when [a].[MOD14]>0 then ([a].[MOD17]/[a].[MOD14]) * 100 else null end
  from @OutT [a]

  select * from @OutT
end