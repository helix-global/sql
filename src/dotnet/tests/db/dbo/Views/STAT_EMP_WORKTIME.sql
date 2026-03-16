
--KB5417:2025-05-20: Initial update.
create view [dbo].[STAT_EMP_WORKTIME] as
with
[source]
  as
  (
  select
     [e].[ID] [EMPID]
    ,isnull([a].[ID],0) [PERSWRKTMHISTID]
    ,[a].[PERSONALWT]
    ,[b].[WTID] [DEPWT]
  from [dbo].[COM_EMPLOYEE] [e]
    left join [dbo].[COM_PERSONALWORKTIME_HISTORY] [a] on [a].[EMPLOYEEID]=[e].[ID]
    left join [dbo].[STAT_DEP_WORKTIME]            [b] on [b].[DEPID]=[e].[DEPID]
  ),
[source_no_schedule]
  as
  (
  select
     [a].[EMPID]
    ,0 [PERSWRKTMHISTID]
    ,[b].[DBEG]
    ,[b].[DEND]
    ,[c].[WTID]
    ,[c].[WTID] [DEPWT]
  from [source] [a]
    inner join [dbo].[STAT_EMP_PERIOD_HIST] [b] on [b].[EMPID]=[a].[EMPID]
    inner join [dbo].[STAT_DEP_WORKTIME]    [c] on [c].[DEPID]=[b].[DEPID]
  where [a].[PERSWRKTMHISTID] = 0
    or ([a].[PERSONALWT] is null
        and (select count(*)
             from [dbo].[COM_PERSONALWORKTIME_HISTORY] [c]
             where [c].[EMPLOYEEID]=[a].[EMPID])=1)
  ),
[source_with_schedule_no_end]
  as
  (
  select
     [a].[EMPID]
    ,[a].[PERSWRKTMHISTID]
    ,cast([b].[DBEG] as date) [DBEG]
    ,[b].[PERSONALWT] [WTID]
    ,[a].[DEPWT]
  from [source] [a]
    inner join [dbo].[COM_PERSONALWORKTIME_HISTORY] [b] on [b].[ID]=[a].[PERSWRKTMHISTID]
  where not ([b].[PERSONALWT] is null
    and (select count(*)
         from [dbo].[COM_PERSONALWORKTIME_HISTORY] [c]
         where [c].[EMPLOYEEID]=[a].[EMPID])=1)
  ),
[source_with_schedule]
  as
  (
  select
     [a].[EMPID]
    ,[a].[PERSWRKTMHISTID]
    ,[a].[DBEG]
    ,isnull((select top 1
               dateadd(dd,-1,[b].[DBEG])
             from [source_with_schedule_no_end] [b]
             where [b].[EMPID]=[a].[EMPID]
               and [b].[DBEG]>[a].[DBEG]
               and [b].[PERSWRKTMHISTID]<>[a].[PERSWRKTMHISTID]),'3000-01-01') [DEND]
    ,[a].[WTID]
    ,[a].[DEPWT]
  from [source_with_schedule_no_end] [a]
  ),
[target]
  as
  (
  select * from [source_with_schedule] union all
  select * from [source_no_schedule]
  ),
[output]
  as
  (
  select
     [a].[EMPID]
    ,case when exists(select * from [dbo].[COM_WORKTIME_BR] [b] where [b].[VNESHID]=[a].[WTID]) then isnull([a].[WTID],[a].[DEPWT]) else [a].[DEPWT] end [WTID]
    ,isnull([a].[WTID],[a].[DEPWT]) [WTORIGID]
    ,[a].[DBEG]
    ,[a].[DEND]
    ,[a].[PERSWRKTMHISTID]
  from [target] [a]
  )

select * from [output]

--select * from [output] [a] order by [a].[EMPID],[a].[DBEG]
--select * from [output] [a] where [a].[EMPID]=3532 order by [a].[EMPID],[a].[DBEG]
--select * from [output] [a] where [a].[SHIFT_FI]=0 order by [a].[EMPID],[a].[DBEG]
--a2l:\\Link=doc.com_employee.65