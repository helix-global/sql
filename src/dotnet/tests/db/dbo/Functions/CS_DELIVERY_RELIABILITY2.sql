--KB5263:2025-07-07: Refactoring
CREATE function [dbo].[CS_DELIVERY_RELIABILITY2](@ModelTypeID int, @UserID int, @DBeg datetime,@DEnd datetime, @AddDays int)
returns @OutT table ([DD] date,[V_PLUS] int,[V_MINUS] int)
begin
  /* KB2100 */
  /* ver.2: KB3324*/
  declare @MTDepID int
  select
    @MTDepID = [a].[DEPARTMENTID]
  from [dbo].[PR_MODELTYPE] [a] with(nolock)
  where [a].[ID]=@ModelTypeID

  declare @tmp table([DEVICEID] int,[SO_ID] int,[CDD] date,[SHREQID] int,[SHDD] date)
  insert into @tmp ([DEVICEID],[SO_ID],[CDD],[SHREQID])
    select
       [dev].[ID]
      ,[sup].[ID]
      ,[sup].[CDD]
      ,(select top 1 [ord].[ID]
        from [SH_ORDER_T] [orT] with(nolock)
          left join [SH_ORDER] [ord] with(nolock) on [ord].[ID]=[orT].[SHORDERID]
        where [orT].[DEVICEID]=[dev].[ID]
          and [ord].[S_S] in (1000024/*shipped*/)
        order by [ord].[ID])
    from [dbo].[PR_DEVICE] [dev] with(nolock)
      left join [dbo].[PR_MODELS] [mdl] with(nolock) on [mdl].[ID]=[dev].[MODELID]
      left join [dbo].[PR_SUPPLY] [sup] with(nolock) on [sup].[ID]=[dev].[SORDERID]
    where [mdl].[TYPEID]=@ModelTypeID
      and [mdl].[DEPID] = @MTDepID
      and [sup].[CDD] >= @DBeg
      and [sup].[CDD] < @DEnd
    -- for temporary request get 'cs_delivery_reliability' report without model start from
    --and (LEFT([B].[CODE], 5) <> 'PLSUB' and LEFT([B].[CODE], 5) <> 'PLSOP' and LEFT([B].[CODE], 4) <> 'PROX')

  update @tmp set
    [SHDD] = (select [ord].[DD]
              from [SH_ORDER] [ord] with(nolock)
              where [ord].[ID] = "@tmp".[SHREQID])

  declare @tmp2 table ([SO_ID] int,[CDD] date,[V_PLUS] int,[V_MINUS] int)
  insert into @tmp2 ([SO_ID],[CDD])
    select distinct
       [SO_ID]
      ,[CDD]
    from @tmp
    where [SHREQID] is not null

  update @tmp2 set [V_PLUS]  = (select count(distinct [A].[SHREQID]) from @tmp [A] where [A].[SO_ID]="@tmp2".[SO_ID] and [A].[SHDD] <= "@tmp2".[CDD])
  update @tmp2 set [V_MINUS] = (select count(distinct [A].[SHREQID]) from @tmp [A] where [A].[SO_ID]="@tmp2".[SO_ID] and dateadd(day,isnull(-@AddDays,0),[A].[SHDD]) > "@tmp2".[CDD])

  insert into @OutT([DD],[V_PLUS],[V_MINUS])
    select
       [CDD]
      ,sum([V_PLUS])
      ,sum([V_MINUS])
    from @tmp2
    group by [CDD]

  return
end