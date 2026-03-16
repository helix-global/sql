
--KB5417:2025-05-20: Initial update.
create view [dbo].[STAT_EMP_PERIOD_HIST] as
with
[!source] as
  (
  select
     row_number() over(order by [e].[ID],[a].[DBEG],[a].[ID] desc) [ID]
    ,[e].[ID] [EMPID]
    ,isnull([a].[DEPID],[e].[DEPID]) [DEPID]
    ,cast(coalesce([a].[DBEG],[e].[EMPDATE],[e].[S_CDT]) as date) [DBEG]
    ,cast(coalesce([a].[DEND],[e].[DISSDATE],'3000-01-01')  as date) [DEND]
    ,[e].[EMPDATE]
    ,cast([e].[DISSDATE] as date) [DISSDATE]
    ,isnull([a].[ID],0) [EMPPERID]
    ,datediff(dd,cast(coalesce([a].[DBEG],[e].[EMPDATE],[e].[S_CDT]) as date),cast(coalesce([a].[DEND],[e].[DISSDATE],'3000-01-01') as date)) [DDUR]
  from [dbo].[COM_EMPLOYEE] [e]
    left join [dbo].[COM_EMPL_PERIODS] [a] on [a].[EMPLID]=[e].[ID]
  ),
[!removing_duplicates] as
  (
  select
     [a].[ID]
    ,[a].[EMPID]
    ,[a].[DEPID]
    ,[a].[DBEG]
    ,[a].[DEND]
    ,[a].[EMPPERID]
    ,[a].[DDUR]
  from [!source] [a]
  where not exists(select * from [!source] [b] where [b].[EMPID]=[a].[EMPID] and [b].[DBEG]=[a].[DBEG] and [b].[ID]< [a].[ID])
    and not exists(select * from [!source] [b] where [b].[EMPID]=[a].[EMPID] and [b].[DEND]=[a].[DEND] and [b].[ID]<>[a].[ID] and [a].[DDUR]=0)
    and not exists(select *
                   from [!source] [b]
                   where [b].[EMPID]=[a].[EMPID]
                     and [b].[ID]<>[a].[ID]
                     and [b].[DBEG] <= [a].[DBEG]
                     and [b].[DEND] >= [a].[DEND])
  ),
[!crossing] as
  (
  select
     [l].[EMPID]
    ,[l].[ID] [LTID]
    ,[r].[ID] [RTID]
    ,[l].[EMPPERID] [LTEMPPERID]
    ,[r].[EMPPERID] [RTEMPPERID]
    ,0-datediff(day,[r].[DBEG],[l].[DEND])-1 [DELTA]
  from [!removing_duplicates] [l]
    inner join [!removing_duplicates] [r] on [r].[ID]>[l].[ID] and [r].[EMPID]=[l].[EMPID]
  where datediff(day,[r].[DBEG],[l].[DEND]) >= 0
  ),
[!target] as
  (
  select
     [src].[ID]
    ,[src].[EMPID]
    ,[src].[DEPID]
    --,[dep].[CODE] [DEPCODE]
    ,[src].[DBEG]
    ,dateadd(day,isnull([cro].[DELTA],0),[src].[DEND]) [DEND]
    ,[src].[EMPPERID]
  from [!removing_duplicates] [src]
    --inner join [dbo].[COM_DEPARTMENTS] [dep] on [dep].[ID]=[src].[DEPID]
    left  join [!crossing]             [cro] on [cro].[LTID]=[src].[ID]
  )
select * from [!target]