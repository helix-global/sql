

--KB5417:2025-05-20: Initial update.
CREATE view [dbo].[STAT_DEP_WORKTIME]
with schemabinding
as 
with
  [PARDEP0]
  as
  (
  select
     [dep].[ID] [DEPID]
    ,[dep].[PARENTDEPARTMENT] [PARDEP0ID]
  from [dbo].[COM_DEPARTMENTS] [dep]
  ),
  [PARDEP1]
  as
  (
  select
     [a].[DEPID]
    ,[a].[PARDEP0ID]
    ,[dep].[PARENTDEPARTMENT] [PARDEP1ID]
  from [PARDEP0] [a]
    left join [dbo].[COM_DEPARTMENTS] [dep] on [dep].[ID]=[a].[PARDEP0ID]
  ),
  [PARDEP2]
  as
  (
  select
     [a].[DEPID]
    ,[a].[PARDEP0ID]
    ,[a].[PARDEP1ID]
    ,[dep].[PARENTDEPARTMENT] [PARDEP2ID]
  from [PARDEP1] [a]
    left join [dbo].[COM_DEPARTMENTS] [dep] on [dep].[ID]=[a].[PARDEP1ID]
  )
select
   [a].[DEPID]
  ,coalesce((select top 1
              [wrk].[ID]
             from [dbo].[COM_WORKTIME] [wrk]
             where [wrk].[DEPID]=[a].[DEPID]
               and [wrk].[S_S] not in (2130054)
               and [wrk].[WTDEFAULT]>0),
            (select top 1
              [wrk].[ID]
             from [dbo].[COM_WORKTIME] [wrk]
             where [wrk].[DEPID]=[a].[PARDEP0ID]
               and [wrk].[S_S] not in (2130054)
               and [wrk].[WTDEFAULT]>0),
            (select top 1
              [wrk].[ID]
             from [dbo].[COM_WORKTIME] [wrk]
             where [wrk].[DEPID]=[a].[PARDEP1ID]
               and [wrk].[S_S] not in (2130054)
               and [wrk].[WTDEFAULT]>0),
            (select top 1
              [wrk].[ID]
             from [dbo].[COM_WORKTIME] [wrk]
             where [wrk].[DEPID]=[a].[PARDEP2ID]
               and [wrk].[S_S] not in (2130054)
               and [wrk].[WTDEFAULT]>0),
            (select top 1
              [wrk].[ID]
             from [dbo].[COM_WORKTIME] [wrk]
             where [wrk].[NAME]='IPGL Default'
               and [wrk].[S_S] not in (2130054)
               and [wrk].[WTDEFAULT]>0),
            0)
    [WTID]
from [PARDEP2] [a]