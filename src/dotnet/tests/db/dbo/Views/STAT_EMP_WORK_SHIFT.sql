
--KB5417:2025-05-20: Initial update.
CREATE view [dbo].[STAT_EMP_WORK_SHIFT] as
with [WORK_SHIFT]
  as
  (
  select
     [a].[ID]
    ,[a].[S_CR]
    ,[a].[S_MR]
    ,[a].[S_CDT]
    ,[a].[S_MDT]
    ,[a].[EMPLID] [EMPID]
    ,[a].[DD]
    ,[a].[WTURN]  [SHIFT]
    ,(select top 1 [wrk].[WTID]
      from [dbo].[STAT_EMP_WORKTIME] [wrk] with(nolock)
        inner join [dbo].[COM_WORKTIME_BR] [wbr] with(nolock) on [wbr].[VNESHID]=[wrk].[WTID]
      where [a].[EMPLID]=[wrk].[EMPID]
        and [a].[DD] between [wrk].[DBEG] and [wrk].[DEND]) [WTID]
  from [dbo].[COM_TURNS] [a]
  )
select
  *
from [WORK_SHIFT] [a]