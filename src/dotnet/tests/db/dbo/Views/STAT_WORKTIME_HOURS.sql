
--KB5417:2025-05-20: Initial update.
create view [dbo].[STAT_WORKTIME_HOURS] as
with [WORKTIME]
  as
  (
  select
     [a].[ID] [WTID]
    ,cast(cast([b].[TFROM] as time) as datetime) + '1900-01-01T00:00:00' [TBEG]
    ,case when cast([b].[TTO] as time)='00:00:00' then
      cast(cast([b].[TTO] as time) as datetime) + '1900-01-02T00:00:00' else
      cast(cast([b].[TTO] as time) as datetime) + '1900-01-01T00:00:00' end [TEND]
    ,isnull([b].[TDEXTDAY],0) [DISPLACEMENT]
    ,[b].[WTURN] [SHIFT]
    ,[b].[ID] [WRKTMBRID]
  from [dbo].[COM_WORKTIME] [a]
    left join [dbo].[COM_WORKTIME_BR] [b] with(nolock) on [b].[VNESHID]=[a].[ID]
  ),
[WORK_TIME_WITH_DISPLACEMENT]
  as
  (
  select
     [a].[WTID]
    ,[a].[WRKTMBRID]
    ,[a].[SHIFT]
    ,[a].[DISPLACEMENT]
    ,case when [a].[DISPLACEMENT]=0 and exists(select *
                                               from [dbo].[COM_WORKTIME_BR] [b] with(nolock)
                                               where [b].[ID]<>[a].[WRKTMBRID]
                                                 and [b].[VNESHID]=[a].[WTID]
                                                 and [b].[WTURN]=[a].[SHIFT]
                                                 and [b].[TDEXTDAY] in (1,2)) then dateadd(dd,1,[a].[TBEG])
          when [a].[DISPLACEMENT]=1 and exists(select *
                                               from [dbo].[COM_WORKTIME_BR] [b] with(nolock)
                                               where [b].[ID]<[a].[WRKTMBRID]
                                                 and [b].[VNESHID]=[a].[WTID]
                                                 and [b].[WTURN]=[a].[SHIFT]
                                                 and [b].[TDEXTDAY] in (1)) then dateadd(dd,1,[a].[TBEG])
     else [a].[TBEG] end [TBEG]
    ,case when [a].[DISPLACEMENT] in (1,2) then dateadd(dd,1,[a].[TEND])
          when [a].[DISPLACEMENT]=0 and exists(select *
                                               from [dbo].[COM_WORKTIME_BR] [b] with(nolock)
                                               where [b].[ID]<>[a].[WRKTMBRID]
                                                 and [b].[VNESHID]=[a].[WTID]
                                                 and [b].[WTURN]=[a].[SHIFT]
                                                 and [b].[TDEXTDAY]in (1,2)) then dateadd(dd,1,[a].[TEND])
    else [a].[TEND] end [TEND]
  from [WORKTIME] [a]
  )
select
  *
from [WORK_TIME_WITH_DISPLACEMENT] [a]