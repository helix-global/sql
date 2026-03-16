-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-09-11
-- Description: Retrieving employee personal worktime for the specified period.
-- =============================================
-- KB5183:2025-01-28: Fixed duplicate overtime records.
--                  : Verification of overtime records that overlap scheduled time.
-- FIX   :2025-01-22: Option for Delete Vacation On Intersect With Siskleave or delete Sickleave on intersect with Vacation {Efimov Maksim}
-- KB5139:2024-12-06: Fixed middle of day using.
-- KB5054:2024-12-02: Including "Kurzarbeit" records.
-- KB4992:2024-09-30: Resolving personal worktime history crossing.
-- KB4914:2024-09-13: Initial update. {Dmitrii Maistrenko}
CREATE function [dbo].[STAT_EMPL_PERSONAL_WORKTIME]
  (
  @DateBeg date,
  @DateEnd date,
  @DepId int,
  @EmpId int,
  @Options nvarchar(max)
  )
returns
  @Output table(
    [MARK] varchar(32),[KIND] int,[DD] date,[ISWORKDAY] int,[DEPID] int,
    [EMPID] int,[TYPE] int,[PERIOD] int,[DUR] int,[PAUSE] int,
    [DBEG] datetime,[DEND] datetime,
    [WTID] int,[SHIFT] int,[EXTID] int,[EXTLB] nvarchar(256)
    unique clustered ([KIND],[DD],[EMPID],[EXTID],[DBEG],[DEND],[TYPE]))
as
begin
  declare @FullDayMinutes float = 480
  declare @OptionsT table ([OPTION] nvarchar(max))
  insert into @OptionsT select [OPTION] from [dbo].[COM_OPT_SPLIT](@Options)

  declare @ChildDepartmentsOption int = 0
  declare @IncludeDepartmentHeadOption int = 0
  declare @IncludeVactionDetail int = 0
  declare @DeleteVacationOnIntersectWithSickLeave int = 0
  declare @IncludeUnapprovedLeaveOption int = 0
  declare @IncludeCanceledLeaveOption int = 0

  if exists(select * from @OptionsT where [OPTION] like 'ChildDepartments')       set @ChildDepartmentsOption = 1
  if exists(select * from @OptionsT where [OPTION] like 'IncludeDepartmentHead')  set @IncludeDepartmentHeadOption = 1
  if exists(select * from @OptionsT where [OPTION] like 'IncludeVactionDetail')   set @IncludeVactionDetail = 1
  if exists(select * from @OptionsT where [OPTION] like 'IncludeUnapprovedLeave') set @IncludeUnapprovedLeaveOption = 1
  if exists(select * from @OptionsT where [OPTION] like 'IncludeCanceledLeave')   set @IncludeCanceledLeaveOption = 1
  /* KB5180 */
  if exists(select * from @OptionsT where [OPTION] like 'DeleteVacationOnIntersectWithSiskleave')  set @DeleteVacationOnIntersectWithSickLeave = 1

  declare @DepT table ([DEPID] int,unique nonclustered ([DEPID]))
  insert into @DepT
    select
      [a].[ID] [DEPID]
    from [dbo].[COM_DEPARTMENTS] [a] with(nolock)
    where ((@DepId = 0) or ([a].[ID]=@DepId) or ((@ChildDepartmentsOption=1) and ([a].[ID] in (select * from [dbo].[COM_GETCHILD_DEPARTMENTS2](@DepId,0)))))

  -- Data on periods of work of employees and a list of those employees who will be further use.
  declare @EmpT table ([EMPID] int,unique nonclustered ([EMPID]))
  declare @EmployeePeriodsSource table([EMPID] int,[WTID] int, [CALENDAR] int, [DEPID] int,[DBEG] date, [DEND] date,[EMPDATE] date,[DISSDATE] date
    ,unique clustered ([EMPID],[DEPID],[DBEG],[DEND])
    ,index [IX-1] ([EMPID],[DEPID])
    ,index [IX-2] ([EMPID]));
  insert into @EmployeePeriodsSource
    select
       [a].[ID] [EMPID]
      ,coalesce([a].[PERSONALWT],[b].[ID]) [WTID]
      ,coalesce([c].[CALENDAR],[b].[CALENDAR],1) [CALENDAR]
      ,isnull([d].[DEPID],[a].[DEPID]) [DEPID]
      ,cast(coalesce([d].[DBEG],[a].[EMPDATE],'1990-01-01') as date) [DBEG]
      ,cast(coalesce([d].[DEND],[a].[DISSDATE],@DateEnd)    as date) [DEND]
      ,[a].[EMPDATE]
      ,[a].[DISSDATE]
    from [dbo].[COM_EMPLOYEE] [a] with(nolock)
      left join [dbo].[COM_WORKTIME]     [b] with(nolock) on ([b].[DEPID] = [a].[DEPID]) and (isnull([b].[WTDEFAULT],0) = 1)
      left join [dbo].[COM_WORKTIME]     [c] with(nolock) on ([c].[ID] = [a].[PERSONALWT])
      left join [dbo].[COM_EMPL_PERIODS] [d] with(nolock) on ([d].[EMPLID]=[a].[ID])
      left join [dbo].[DEF_USERS]        [u] with (nolock) on [u].[EMPLOYEEID] = [a].[ID]
    where ((@EmpId=0) or ([a].[ID]=@EmpId))
      and ((([a].[DISSDATE] is null) /*and ([a].[S_S] <> 1000092)*/) or ([a].[DISSDATE] >= @DateBeg))
      and (([a].[EMPDATE]  is null) or ([a].[EMPDATE] <= @DateEnd))
      and (((not exists(select * from [dbo].[COM_EMPL_PERIODS] with(nolock) where [EMPLID]=[a].[ID])) and ([a].[DEPID] in (select * from @DepT))) or (
                ([d].[ID] is not null)
            and (([d].[DBEG] is null) or ([d].[DBEG] <= @DateEnd))
            and (([d].[DEND] is null) or ([d].[DEND] >= @DateBeg))
            and ((([d].[DEPID] is null) and ([a].[DEPID] in (select * from @DepT))) or ([d].[DEPID] in (select * from @DepT)))))
      and ((@IncludeDepartmentHeadOption=1) or ([dbo].DEF_USERINGROUP7([u].[ID], 'DH&VICE') = 0))

  --select * from @EmployeePeriodsSource

  declare @EmployeePeriods table([ID] int identity,[EMPID] int,[WTID] int, [CALENDAR] int, [DEPID] int
    ,[DBEG] date, [DEND] date
    ,[SHIFT_FI] int /* Has first  shift in personal working period */
    ,[SHIFT_SE] int /* Has second shift in personal working period */
    ,[SHIFT_TH] int /* Has third  shift in personal working period */
    ,[SHIFT_FO] int /* Has fourth shift in personal working period */
    ,[EMPDATE] date,[DISSDATE] date
    ,unique clustered ([EMPID],[DEPID],[DBEG],[DEND])
    ,index [IX-1] ([EMPID],[DEPID])
    ,index [IX-2] ([EMPID])
    ,index [IX-3] ([ID],[EMPID])
    ,index [IX-4] ([ID]));
  with
  [EMPLOYEE_PERIODS_WTID] as
    (
    select
        [a].[EMPID]
       ,coalesce([a].[WTID],[c].[ID],[e].[ID],
        (
         select top 1 [ID]
         from [dbo].[COM_WORKTIME] with(nolock)
         where ([DEPID]=[a].[DEPID])
           and ([S_CDT]<=[a].[DBEG])
           and ([S_S] not in (2130054))
         order by isnull([WTDEFAULT],1) desc,[S_CDT] desc
        ),
        (
         select top 1 [ID]
         from [dbo].[COM_WORKTIME] with(nolock)
         where ([DEPID]=[b].[PARENTDEPARTMENT])
           and ([S_CDT]<=[a].[DBEG])
           and ([S_S] not in (2130054))
         order by isnull([WTDEFAULT],1) desc,[S_CDT] desc
        ),
        (
         select top 1 [ID]
         from [dbo].[COM_WORKTIME] with(nolock)
         where ([DEPID]=[d].[PARENTDEPARTMENT])
           and ([S_CDT]<=[a].[DBEG])
           and ([S_S] not in (2130054))
         order by isnull([WTDEFAULT],1) desc,[S_CDT] desc
        )
        ,
        (
         select top 1 [ID]
         from [dbo].[COM_WORKTIME] with(nolock)
         where ([NAME]='IPGL Default')
           and ([S_S] not in (2130054))
         order by isnull([WTDEFAULT],1) desc,[S_CDT] desc
        )) [WTID]
      ,[a].[CALENDAR]
      ,[a].[DEPID]
      ,[a].[DBEG]
      ,[a].[DEND]
      ,[a].[EMPDATE]
      ,[a].[DISSDATE]
    from @EmployeePeriodsSource [a]
      inner join [dbo].[COM_DEPARTMENTS] [b] with(nolock) on ([b].[ID]=[a].[DEPID])
      left  join [dbo].[COM_DEPARTMENTS] [d] with(nolock) on ([d].[ID]=[b].[PARENTDEPARTMENT])
      left  join [dbo].[COM_WORKTIME]    [c] with(nolock) on ([c].[DEPID] = [d].[ID]) and (isnull([c].[WTDEFAULT],0) = 1)
      left  join [dbo].[COM_WORKTIME]    [e] with(nolock) on ([e].[DEPID] = [d].[PARENTDEPARTMENT]) and (isnull([e].[WTDEFAULT],0) = 1)
    ),
  [EMPLOYEE_PERIODS_SHIFT] as
    (
    select
       [a].[EMPID]
      ,[a].[WTID]
      ,[a].[CALENDAR]
      ,[a].[DEPID]
      ,[a].[DBEG]
      ,[a].[DEND]
      ,case when exists(select * from [dbo].[COM_WORKTIME_BR] [b] with(nolock) where ([b].[VNESHID]=[a].[WTID]) and ([b].[WTURN]=1)) then 1 else 0 end [SHIFT_FI]
      ,case when exists(select * from [dbo].[COM_WORKTIME_BR] [b] with(nolock) where ([b].[VNESHID]=[a].[WTID]) and ([b].[WTURN]=2)) then 1 else 0 end [SHIFT_SE]
      ,case when exists(select * from [dbo].[COM_WORKTIME_BR] [b] with(nolock) where ([b].[VNESHID]=[a].[WTID]) and ([b].[WTURN]=3)) then 1 else 0 end [SHIFT_TH]
      ,case when exists(select * from [dbo].[COM_WORKTIME_BR] [b] with(nolock) where ([b].[VNESHID]=[a].[WTID]) and ([b].[WTURN]=4)) then 1 else 0 end [SHIFT_FO]
      ,[a].[EMPDATE]
      ,[a].[DISSDATE]
    from [EMPLOYEE_PERIODS_WTID] [a]
    )
  insert into @EmployeePeriods
    select
       [a].[EMPID]
      ,[a].[WTID]
      ,[a].[CALENDAR]
      ,[a].[DEPID]
      ,[a].[DBEG]
      ,[a].[DEND]
      ,case when [a].[WTID] is null then 0 else [a].[SHIFT_FI] end [SHIFT_FI]
      ,case when [a].[WTID] is null then 0 else [a].[SHIFT_SE] end [SHIFT_SE]
      ,case when [a].[WTID] is null then 0 else [a].[SHIFT_TH] end [SHIFT_TH]
      ,case when [a].[WTID] is null then 0 else [a].[SHIFT_FO] end [SHIFT_FO]
      ,[a].[EMPDATE]
      ,[a].[DISSDATE]
    from [EMPLOYEE_PERIODS_SHIFT] [a]
      inner join [dbo].[COM_EMPLOYEE] [e] on [e].[ID]=[a].[EMPID]
    where ([a].[DISSDATE] is not null) or ([e].[S_S]=1)
    order by [a].[DBEG]
  insert into @EmpT select distinct [a].[EMPID] from @EmployeePeriods [a]
  --select * from @EmployeePeriods

  -- Validating for period crossing
  declare @EmployeePeriodCrossing table([LEFTID] int,[RIGHTID] int,[DELTA] int, index [IX-1] ([LEFTID]))
  while 1=1
  begin
    delete from @EmployeePeriodCrossing
    insert into @EmployeePeriodCrossing
      select
         [l].[ID]
        ,[r].[ID]
        ,0-datediff(day,[r].[DBEG],[l].[DEND])-1 [DELTA]
      from @EmployeePeriods [l]
        inner join @EmployeePeriods [r] on [r].[ID]>[l].[ID] and [r].[EMPID]=[l].[EMPID]
      where datediff(day,[r].[DBEG],[l].[DEND]) >= 0
      order by [l].[DBEG]
    --select * from @EmployeePeriodCrossing
    if not exists(select * from @EmployeePeriodCrossing) break

    -- Shifts the first day of the crossed period by delta to take of the crossing
    update [l]
      set [l].[DEND]=dateadd(day,[c].[DELTA],[l].[DEND])
    from @EmployeePeriods [l]
      inner join @EmployeePeriodCrossing [c] on [c].[LEFTID]=[l].[ID]
      inner join @EmployeePeriods        [r] on [r].[ID]=[c].[RIGHTID]
  end

  -- Building personal work-time history table
  declare @PersonalWorktimeHistoryT table([PERSWRKTMHISTID] int,[EMPID] int,[WTID] int
    ,[DBEG] date,[DEND] date
    ,index [IX-2] ([PERSWRKTMHISTID])
    ,index [IX-1] ([EMPID],[DBEG])
    ,index [IX-3] ([EMPID],[WTID],[DBEG],[DEND]))
  insert into @PersonalWorktimeHistoryT ([PERSWRKTMHISTID],[EMPID],[WTID],[DBEG])
    select
       [a].[ID]
      ,[a].[EMPLOYEEID]
      ,isnull([a].[PERSONALWT],836)
      ,[a].[DBEG]
    from [dbo].[COM_PERSONALWORKTIME_HISTORY] [a] with(nolock)
    where ([a].[EMPLOYEEID]=@EmpId or @EmpId=0)

  --#region Deletes duplicated records
  delete from [a]
  from @PersonalWorktimeHistoryT [a]
    inner join @PersonalWorktimeHistoryT [b] on [b].[DBEG]=[a].[DBEG]
                                            and [b].[EMPID]=[a].[EMPID]
                                            and [b].[PERSWRKTMHISTID]>[a].[PERSWRKTMHISTID]
  --#endregion

  update [a] set
    [a].[DEND]=isnull((
                select top 1
                  dateadd(dd,-1,[b].[DBEG])
                from @PersonalWorktimeHistoryT [b]
                where [b].[EMPID]=[a].[EMPID]
                  and [b].[DBEG]>[a].[DBEG]
                order by [b].[DBEG]),@DateEnd)
  from @PersonalWorktimeHistoryT [a]

  insert into @PersonalWorktimeHistoryT(
    [PERSWRKTMHISTID],[EMPID],[WTID],[DBEG],[DEND])
    select
       0
      ,[a].[EMPID]
      ,[a].[WTID]
      ,[a].[DBEG]
      ,[a].[DEND]
    from @EmployeePeriods [a]
    where not exists(select * from @PersonalWorktimeHistoryT [b] where [b].[EMPID]=[a].[EMPID])

  --select * from @PersonalWorktimeHistoryT

  declare @PersonalWorktimeT table([WTID] int,[SHIFT] int,[EMPID] int
    ,[TBEG] datetime,[TMID] datetime,[TEND] datetime,[WORKMINUTES] int,[EXTID] int
    ,[WORK_FORENOON] int,[WORK_AFTRNOON] int
    ,index [IX-1] clustered ([WTID],[SHIFT],[EMPID]));
  declare @PersonalWorktimeG table([WTID] int,[SHIFT] int,[EMPID] int
    ,[TBEG] datetime,[TEND] datetime,[TMID] datetime
    ,[WORKMINUTES] int,[PAUSE] int
    ,[WORK_FORENOON]  int,[WORK_AFTRNOON]  int
    ,[PAUSE_FORENOON] int,[PAUSE_AFTRNOON] int
    ,index [IX-1] clustered ([EMPID],[WTID],[SHIFT]));
  with
  [WORK_TIME] as
    (
    select
      isnull([a].[WTID],0)  [WTID]
     ,isnull([b].[WTURN],0) [SHIFT]
     ,[a].[EMPID]
     ,cast(cast([b].[TFROM] as time) as datetime) + '1900-01-01T00:00:00' [TBEG]
     ,case when cast([b].[TTO] as time)='00:00:00' then
        cast(cast([b].[TTO] as time) as datetime) + '1900-01-02T00:00:00' else
        cast(cast([b].[TTO] as time) as datetime) + '1900-01-01T00:00:00' end [TEND]
     ,isnull([b].[TDEXTDAY],0) [DISPLACEMENT]
     ,[b].[ID] [EXTID]
    from (select distinct [WTID],[EMPID] from @PersonalWorktimeHistoryT) [a]
      left join [dbo].[COM_WORKTIME_BR] [b] with(nolock) on [b].[VNESHID]=[a].[WTID]
    ),
  [WORK_TIME_WITH_DISPLACEMENT] as
    (
    select
       [a].[WTID]
      ,[a].[SHIFT]
      ,[a].[EMPID]
      ,isnull(case when ([a].[DISPLACEMENT]=2 or [a].[SHIFT]>2) and ([a].[TBEG]<'1900-01-01T18:00:00') then dateadd(dd,1,[a].[TBEG]) else [a].[TBEG] end,'1900-01-01T08:00:00') [TBEG]
      ,isnull(case when ([a].[DISPLACEMENT]=2 or [a].[SHIFT]>2) and ([a].[TEND]<'1900-01-01T18:00:00') then dateadd(dd,1,[a].[TEND]) else [a].[TEND] end,'1900-01-01T17:00:00') [TEND]
      ,[a].[DISPLACEMENT]
      ,[a].[EXTID]
      ,dateadd(dd,case when [a].[SHIFT]>2 then 1 else 0 end,(
        select top 1 cast(cast([b].[WTURN_MIDDLE] as time) as datetime)
        from [dbo].[COM_WORKTIME_SH] [b] with(nolock)
        where [b].[VNESHID]=[a].[WTID]
          and [b].[WTURN]=[a].[SHIFT])) [TMID]
      ,(select top 1 min([b].[TBEG]) from [WORK_TIME] [b] where [b].[EMPID]=[a].[EMPID] and [b].[WTID]=[a].[WTID] and [b].[SHIFT]=[a].[SHIFT]) [MIN_TBEG]
      ,(select top 1 max([b].[TEND]) from [WORK_TIME] [b] where [b].[EMPID]=[a].[EMPID] and [b].[WTID]=[a].[WTID] and [b].[SHIFT]=[a].[SHIFT]) [MAX_TEND]
    from [WORK_TIME] [a]
    ),
  [WORK_TIME_WITH_MIDDLE] as
    (
    select
       [a].[WTID]
      ,[a].[SHIFT]
      ,[a].[EMPID]
      ,[a].[TBEG]
      ,[a].[TEND]
      ,[a].[EXTID]
      ,case when [a].[TMID] is not null then [a].[TMID]
      else
        dateadd(dd,case when [a].[SHIFT]>2 then 1 else 0 end,(dateadd(mi,datediff(mi,[a].[MIN_TBEG],[a].[MAX_TEND])*0.5,[a].[MIN_TBEG])))
      end [TMID]
      ,[a].[MIN_TBEG]
      ,[a].[MAX_TEND]
    from [WORK_TIME_WITH_DISPLACEMENT] [a]
    )
  insert into @PersonalWorktimeT([WTID],[SHIFT],[EMPID],[TBEG],[TMID],[TEND],[WORKMINUTES],[EXTID],[WORK_FORENOON],[WORK_AFTRNOON])
    select
       [a].[WTID]
      ,[a].[SHIFT]
      ,[a].[EMPID]
      ,[a].[TBEG]
      ,[a].[TMID]
      ,[a].[TEND]
      ,datediff(mi,[a].[TBEG],[a].[TEND]) [WORKMINUTES]
      ,[a].[EXTID]
      /* Count working minutes relative to the "middle" of the working day part:
         [WORK_FORENOON]: before noon
         [WORK_AFTRNOON]: after noon
      */
      ,isnull((select sum(datediff(mi,[o].[DBEG],[o].[DEND])) from [dbo].[COM_DATE_PERIOD_SUBSTRACT]([a].[TBEG],[a].[TEND],[a].[TMID],[a].[TEND]) [o]),0) [WORK_FORENOON]
      ,isnull((select sum(datediff(mi,[o].[DBEG],[o].[DEND])) from [dbo].[COM_DATE_PERIOD_SUBSTRACT]([a].[TBEG],[a].[TEND],[a].[TBEG],[a].[TMID]) [o]),0) [WORK_AFTRNOON]
      --,[a].[MIN_TBEG]
      --,[a].[MAX_TEND]
      --,datediff(mi,[a].[MIN_TBEG],[a].[MAX_TEND])
    from [WORK_TIME_WITH_MIDDLE] [a];

  declare @MiddleDayT table([WTID] int,[SHIFT] int,[EMPID] int,[TMID] datetime,index [WTID_SHIFT_EMPID] ([WTID],[SHIFT],[EMPID]))
  insert into @MiddleDayT
    select distinct
       [a].[WTID]
      ,[a].[SHIFT]
      ,[a].[EMPID]
      ,[a].[TMID]
    from @PersonalWorktimeT [a]

  --select * from @PersonalWorktimeT
  --select * from @MiddleDayT

  --select
  --   [a].[WTID]
  --  ,[a].[SHIFT]
  --  ,[a].[EMPID]
  --  ,[a].[TBEG]
  --  ,[a].[TEND]
  --  ,[b].[TBEG]
  --  ,[b].[TEND]
  --from @PersonalWorktimeT [a]
  --  inner join @PersonalWorktimeT [b] on [b].[EXTID]<>[a].[EXTID]
  --                               and [b].[EMPID]=[a].[EMPID]
  --                               and [b].[SHIFT]=[a].[SHIFT]
  --                               and [b].[WTID]=[a].[WTID]
  --where [a].[TBEG]<[b].[TBEG]

  ;with [PERSONAL_WORK_TIME] as
    (
    select
       [a].[WTID]
      ,[a].[SHIFT]
      ,[a].[EMPID]
      ,min([a].[TBEG]) [TBEG]
      ,max([a].[TEND]) [TEND]
      ,isnull(sum(datediff(mi,[a].[TBEG],[a].[TEND])),480) [WORKMINUTES]
      ,sum([a].[WORK_FORENOON]) [WORK_FORENOON]
      ,sum([a].[WORK_AFTRNOON]) [WORK_AFTRNOON]
    from @PersonalWorktimeT [a]
    group by
      [a].[WTID]
     ,[a].[SHIFT]
     ,[a].[EMPID]
     ),
  [PERSONAL_WORK_TIME_WITH_MIDDLE] as
    (
    select
       [a].[WTID]
      ,[a].[SHIFT]
      ,[a].[EMPID]
      ,[a].[TBEG]
      ,[a].[TEND]
      ,[a].[WORKMINUTES]
      ,datediff(mi,[a].[TBEG],[a].[TEND])-[WORKMINUTES] [PAUSE]
      ,(
        select top 1 [b].[TMID]
        from @MiddleDayT [b]
        where [b].[WTID]=[a].[WTID]
          and [b].[SHIFT]=[a].[SHIFT]
          and [b].[EMPID]=[a].[EMPID]
        ) [TMID]
      ,[a].[WORK_FORENOON]
      ,[a].[WORK_AFTRNOON]
    from [PERSONAL_WORK_TIME] [a]
    )
  insert into @PersonalWorktimeG([WTID],[SHIFT],[EMPID],[TBEG],[TEND],[WORKMINUTES],[PAUSE],[TMID],[WORK_FORENOON],[WORK_AFTRNOON],[PAUSE_FORENOON],[PAUSE_AFTRNOON])
    select
       [a].[WTID]
      ,[a].[SHIFT]
      ,[a].[EMPID]
      ,[a].[TBEG]
      ,[a].[TEND]
      ,[a].[WORKMINUTES]
      ,[a].[PAUSE]
      ,[a].[TMID]
      ,[a].[WORK_FORENOON]
      ,[a].[WORK_AFTRNOON]
      /* Count pause minutes relative to the "middle" of the working day:
         [PAUSE_FORENOON]: before noon
         [PAUSE_AFTRNOON]: after noon
      */
      ,datediff(mi,[a].[TBEG],[a].[TMID])-[a].[WORK_FORENOON] [PAUSE_FORENOON]
      ,datediff(mi,[a].[TMID],[a].[TEND])-[a].[WORK_AFTRNOON] [PAUSE_AFTRNOON]
    from [PERSONAL_WORK_TIME_WITH_MIDDLE] [a]

  --select * from @PersonalWorktimeG [a] order by [a].[WTID],[a].[SHIFT]

  -- Generating a flat list for calendar days
  declare @WORK_DAYS table([DD] date,[OFFSET] int,[WEEKDAY] int,[WEEK] int,unique clustered ([DD]));
  with [WORK_DAYS]
  as
    (
    select
       @DateBeg [DD]
      ,datediff(dd,'1900-01-01',@DateBeg) [OFFSET]
     union all select
       dateadd(day,1,[a].[DD])
      ,[a].[OFFSET]+1
      from [WORK_DAYS] [a] where [a].[DD]<@DateEnd
    )
  insert into @WORK_DAYS
    select
       [a].[DD]
      ,[a].[OFFSET]
      ,(@@datefirst+datepart(weekday,[a].[DD])-2)%7+1
      ,datepart(iso_week,[a].[DD])
    from [WORK_DAYS] [a] option (maxrecursion 0)

  -- We create a flat list for calendar days in relation to each employee
  declare @EmployeeWorkDaysT table ([WORKDAY] int identity,[DD] date,[EMPID] int, [DEPID] int,[WEEK] int,[WEEKDAY] int,[CALENDAR] int,[WTID] int,[ISWORKDAY] int
    ,[SHIFT] int /* Shift */
    ,[OBEG] datetime,[OEND] datetime,[BASEMINUTES] int
    ,[OFFSET] int,[DBEG] datetime,[DEND] datetime
    ,[PAUSE_B] int
    ,[PAUSE_A] int
    ,unique clustered ([WORKDAY])
    ,index [IX_1] ([DD],[EMPID]));
  with
  [EMPLOYEE_WORK_DAYS] as
    (
    select
       [a].[EMPID]
      ,[c].[DEPID]
      ,[b].[DD]
      ,[b].[WEEK]
      ,[p].[WTID]     [WTID]
      ,[f].[CALENDAR] [CALENDAR]
      ,case when [d].[ID] is null then 0 else 1 end [ISNWWEEK]
      ,case when [e].[ID] is null then 0 else 1 end [ISNWDAY]
      ,case when [b].[WEEKDAY]=1 then isnull([f].[WD1],1) -- Mon
            when [b].[WEEKDAY]=2 then isnull([f].[WD2],1) -- Tue
            when [b].[WEEKDAY]=3 then isnull([f].[WD3],1) -- Wed
            when [b].[WEEKDAY]=4 then isnull([f].[WD4],1) -- Thu
            when [b].[WEEKDAY]=5 then isnull([f].[WD5],1) -- Fri
            when [b].[WEEKDAY]=6 then isnull([f].[WD6],0) -- Sat
            when [b].[WEEKDAY]=7 then isnull([f].[WD7],0) -- Sun
       else null end [ISWORKTIME]
      ,case when [g].[DAYSTATUS]=2 then 1 else 0 end [ISHOLIDAY]
      ,[b].[WEEKDAY]
      ,coalesce(
           (
           -- Obtaining actual work shift from [dbo].[COM_TURNS]
           select top 1 [turn].[WTURN]
           from [dbo].[COM_TURNS] [turn] with(nolock)
           where [turn].[DD]=[b].[DD]
             and [turn].[EMPLID]=[a].[EMPID]
           ),
           -- Obtaining work shift by "kurzarbeit" records.
           (
           select top 1 [w].[SHIFT]
           from [dbo].[COM_VACATION] [v] with(nolock)
             inner join @PersonalWorktimeG [w] on [w].[EMPID]=[v].[EMPLID]
           where [v].[VACATIONTYPE]=200
             and [v].[EMPLID]=[a].[EMPID]
             and [v].[DBEG]=[b].[DD]
             and [w].[WTID]=[p].[WTID]
             and [v].[SHORTSTART]>=dateadd(dd,[b].[OFFSET],[w].[TBEG])
             and dateadd(mi,[v].[SHORTDURATION],[v].[SHORTSTART])<=dateadd(dd,[b].[OFFSET],[w].[TEND])
           ),
           -- KB5158:
           -- Obtaining work shift by "short absence" records that are greater than or equal to the base time.
           (
           select top 1 [w].[SHIFT]
           from [dbo].[COM_VACATION] [v] with(nolock)
             inner join @PersonalWorktimeG [w] on [w].[EMPID]=[v].[EMPLID]
           where [v].[VACATIONTYPE]=30
             and [v].[EMPLID]=[a].[EMPID]
             and [v].[DBEG]=[b].[DD]
             and [w].[WTID]=[p].[WTID]
             and [v].[SHORTDURATION]>=[w].[WORKMINUTES]
             and [dbo].[COM_DATE_IN_PERIOD](
              [dbo].[COM_DATE_REPLACE_DATEPART]([v].[SHORTSTART],[b].[DD]),
              dateadd(mi,[v].[SHORTDURATION],[dbo].[COM_DATE_REPLACE_DATEPART]([v].[SHORTSTART],[b].[DD])),
              dateadd(dd,[b].[OFFSET],[w].[TMID]))=1
           ),
           1) [SHIFT]
      ,null [OBEG]
      ,null [OEND]
      ,[b].[OFFSET]
    from @EmpT [a]
      cross join @WORK_DAYS [b]
      inner join @EmployeePeriods              [c]              on ([b].[DD]>=[c].[DBEG]) and ([b].[DD] <= [c].[DEND]) and ([c].[EMPID]=[a].[EMPID])
      inner join @PersonalWorktimeHistoryT     [p]              on ([b].[DD]>=[p].[DBEG]) and ([b].[DD] <= [p].[DEND]) and ([p].[EMPID]=[a].[EMPID])
      left  join [dbo].[COM_WORKTIME_NW_WEEKS] [d] with(nolock) on ([d].[VNESHID]=[p].[WTID]) and ([d].[WEEKN]=[b].[WEEK])
      left  join [dbo].[COM_WORKTIME_NW_DAYS]  [e] with(nolock) on ([e].[VNESHID]=[p].[WTID]) and ([e].[DDAY]=[b].[DD])
      left  join [dbo].[COM_WORKTIME]          [f] with(nolock) on ([f].[ID]=[p].[WTID])
      left  join [dbo].[COM_CALENDAR]          [g] with(nolock) on ([g].[CALENDAR]=[f].[CALENDAR]) and ([g].[DDAY]=[b].[DD])
      )
  insert into @EmployeeWorkDaysT(
      [DD],[EMPID],[DEPID],[WEEK],[WEEKDAY],[CALENDAR],
      [WTID],[ISWORKDAY],[SHIFT],[OBEG],[OEND],[BASEMINUTES],[OFFSET],
      [DBEG],[DEND],[PAUSE_B])
    select distinct
       [a].[DD]
      ,[a].[EMPID]
      ,[a].[DEPID]
      ,[a].[WEEK]
      ,[a].[WEEKDAY]
      ,[a].[CALENDAR]
      ,[a].[WTID]
      ,case when [a].[ISNWDAY]=1   then 0
            when [a].[ISNWWEEK]=1  then 0
            when [a].[ISHOLIDAY]=1 then 0
            else [a].[ISWORKTIME] end [ISWORKDAY]
      ,[a].[SHIFT]
      ,[a].[OBEG]
      ,[a].[OEND]
      ,[b].[WORKMINUTES]
      ,[a].[OFFSET]
      ,dateadd(dd,[a].[OFFSET],[b].[TBEG])
      ,dateadd(dd,[a].[OFFSET],[b].[TEND])
      ,[b].[PAUSE]
    from [EMPLOYEE_WORK_DAYS] [a]
      left join @PersonalWorktimeG [b] on [b].[WTID]=[a].[WTID] and [b].[SHIFT]=[a].[SHIFT] and [b].[EMPID]=[a].[EMPID]

      --select * from @EmployeeWorkDaysT
  begin -- Fetching overtime records.
    declare @EmplOvertimeG table ([WORKDAY] int,[EMPID] int,[TYPE] int,[DUR] int,unique clustered ([WORKDAY],[EMPID],[TYPE]))
    declare @EmplOvertimeA table (
       [DD] date,[WORKDAY] int,[EMPID] int
      ,[TYPE] int,[DUR] int
      ,[OBEG] datetime,[OEND] datetime
      ,[WTID] int
      ,[SHIFT] int,[EXTID] int
      ,index [IX-1] ([WORKDAY],[EMPID],[TYPE])
      ,index [IX-2] ([WORKDAY],[OBEG],[OEND]));
    with [OVERTIME]
    as
      (
      select
         [c].[DD]
        ,[c].[WORKDAY]
        ,[a].[EMPID]
        ,isnull([b].[OVERTIME_TYPE],0) [TYPE]
        ,case when cast([b].[DBEG] as date) = cast([b].[DEND] as date) then datediff(mi,[b].[DBEG],[b].[DEND])
              when cast([b].[DBEG] as date) = [c].[DD] then datediff(mi,[b].[DBEG],dateadd(ss,1,cast(dateadd(dd,1,[c].[DD]) as datetime)))
              when cast([b].[DEND] as date) = [c].[DD] then datediff(mi,cast([c].[DD] as datetime),[b].[DEND])
         end [DUR]
        ,[dbo].[COM_DATETRUNC_MI](case when cast([b].[DBEG] as time)='00:00' then dateadd(dd,1,[b].[DBEG]) else [b].[DBEG] end) [OBEG]
        ,[dbo].[COM_DATETRUNC_MI](case when cast([b].[DBEG] as time)='00:00' then dateadd(dd,1,[b].[DEND]) else [b].[DEND] end) [OEND]
        ,[c].[WTID]
        ,[c].[SHIFT]
        ,[b].[ID] [EXTID]
      from @EmpT [a]
        inner join [dbo].[COM_ADDED_WORKTIME] [b] with(nolock) on [b].[EMPLID]=[a].[EMPID]
        inner join @EmployeeWorkDaysT [c] on ([c].[EMPID]=[a].[EMPID]) and ([c].[DD]=cast([b].[DBEG] as date) or ([c].[DD]=cast([b].[DEND] as date)))
        )
    insert into @EmplOvertimeA
      select
         [a].[DD]
        ,[a].[WORKDAY]
        ,[a].[EMPID]
        ,[a].[TYPE]
        ,[a].[DUR]
        ,[a].[OBEG]
        ,[a].[OEND]
        ,[a].[WTID]
        ,[a].[SHIFT]
        ,[a].[EXTID]
      from [OVERTIME] [a]
      where [a].[DUR]<>0 --KB5183: Include only relevant records. Otherwise, we will get duplicate records in the future.

      update [a] set
         [a].[OBEG]=(select top 1 [b].[OBEG] from @EmplOvertimeA [b] where [b].[WORKDAY]=[a].[WORKDAY] order by [b].[OBEG]  asc)
        ,[a].[OEND]=(select top 1 [b].[OEND] from @EmplOvertimeA [b] where [b].[WORKDAY]=[a].[WORKDAY] order by [b].[OEND] desc)
      from @EmployeeWorkDaysT [a]
      where exists(select * from @EmplOvertimeA [b] where [b].[WORKDAY]=[a].[WORKDAY])
  end
  begin -- Actual working periods
    declare @EmployeeWorkPeriodsT table(
       [ID] int identity
      ,[WORKDAY] int,[DBEG] datetime,[DEND] datetime,[EXTID] int,[EXTLB] nvarchar(256)
      ,index [IX-1] clustered ([WORKDAY],[DBEG],[DEND])
      ,index [IX-2] ([WORKDAY],[DBEG])
      ,index [IX-3] ([WORKDAY],[DEND])
      ,primary key ([ID]))
    insert into @EmployeeWorkPeriodsT([WORKDAY],[DBEG],[DEND],[EXTID],[EXTLB])
      select
         [b].[WORKDAY]
        ,dateadd(dd,[b].[OFFSET],[a].[TBEG]) [DBEG]
        ,dateadd(dd,[b].[OFFSET],[a].[TEND]) [DEND]
        ,[a].[EXTID]
        ,N'COM_WORKTIME_BR'
      from @PersonalWorktimeT [a]
        inner join @EmployeeWorkDaysT [b] on [b].[EMPID]=[a].[EMPID] and [b].[SHIFT]=[a].[SHIFT] and [b].[WTID]=[a].[WTID]

    declare @EmplOvertimeB table (
       [DD] date,[WORKDAY] int,[EMPID] int
      ,[TYPE] int,[DUR] int
      ,[OBEG] datetime,[OEND] datetime
      ,[WTID] int
      ,[SHIFT] int,[EXTID] int
      ,index [IX-1] ([WORKDAY],[EMPID],[TYPE])
      ,index [IX-2] ([WORKDAY],[OBEG],[OEND]))

    -- Checks to be sure that overtime records do not match scheduled hours (only for work day).
    insert into @EmplOvertimeB
      select distinct
         [a].[DD]
        ,[a].[WORKDAY]
        ,[a].[EMPID]
        ,[a].[TYPE]
        ,datediff(mi,[c].[DBEG],[c].[DEND]) [DUR]
        ,[c].[DBEG]
        ,[c].[DEND]
        ,[a].[WTID]
        ,[a].[SHIFT]
        ,[a].[EXTID]
      from @EmplOvertimeA [a]
        inner join @EmployeeWorkPeriodsT [b] on [b].[WORKDAY]=[a].[WORKDAY]
        inner join @EmployeeWorkDaysT    [d] on [d].[WORKDAY]=[a].[WORKDAY]
        cross apply [dbo].[COM_DATE_PERIOD_SUBSTRACT]([a].[OBEG],[a].[OEND],[b].[DBEG],[b].[DEND]) [c]
      where [dbo].[COM_DATE_PERIOD_IS_OVERLAPED]([a].[OBEG],[a].[OEND],[b].[DBEG],[b].[DEND])>0
        and [d].[ISWORKDAY]=1

    -- Copies overtime records (holiday only).
    insert into @EmplOvertimeB
      select distinct
         [a].[DD]
        ,[a].[WORKDAY]
        ,[a].[EMPID]
        ,[a].[TYPE]
        ,[a].[DUR]
        ,[a].[OBEG]
        ,[a].[OEND]
        ,[a].[WTID]
        ,[a].[SHIFT]
        ,[a].[EXTID]
      from @EmplOvertimeA [a]
        inner join @EmployeeWorkPeriodsT [b] on [b].[WORKDAY]=[a].[WORKDAY]
        inner join @EmployeeWorkDaysT    [d] on [d].[WORKDAY]=[a].[WORKDAY]
      where ([d].[ISWORKDAY]=0)
         or (([dbo].[COM_DATE_PERIOD_IS_OVERLAPED]([a].[OBEG],[a].[OEND],[b].[DBEG],[b].[DEND])<0) and ([d].[ISWORKDAY]=1))

      insert into @EmplOvertimeG
        select
          [a].[WORKDAY]
         ,[a].[EMPID]
         ,[a].[TYPE]
         ,sum([a].[DUR])
        from
          (
          select distinct * from @EmplOvertimeB [a]
          ) [a]
        group by
          [a].[WORKDAY]
         ,[a].[EMPID]
         ,[a].[TYPE]

    merge @EmployeeWorkPeriodsT [a]
    using
      (
      select
         [a].[WORKDAY]
        ,[a].[OBEG]  [DBEG]
        ,[a].[OEND]  [DEND]
        ,[a].[EXTID] [EXTID]
      from @EmplOvertimeB [a]
      ) [b] on [a].[WORKDAY]=[b].[WORKDAY] and [a].[DBEG]=[b].[DBEG] and [a].[DEND]=[b].[DEND]
    when not matched then
      insert ([WORKDAY],[DBEG],[DEND],[EXTID],[EXTLB])
      values ([b].[WORKDAY],[b].[DBEG],[b].[DEND],[b].[EXTID],N'COM_ADDED_WORKTIME');

    /*delete [a]
    from @EmployeeWorkPeriodsT [a]
    where exists(select *
                 from @EmployeeWorkPeriodsT [b]
                 where [a].[DBEG]>=[b].[DBEG] and [a].[DEND]<=[b].[DEND] and [a].[ID]<>[b].[ID])*/

    declare @EmployeeWorkPeriodsP table([ID] int identity,
       [WORKDAY] int,[DBEG] datetime,[DEND] datetime,[PAUSE] int
      ,index [IX-1] ([WORKDAY])
      ,index [IX-2] ([WORKDAY],[DBEG],[DEND])
      ,primary key clustered ([ID]));
    with [T] as
      (
      select
         [a].[WORKDAY]
        ,[a].[DBEG]
        ,[a].[DEND]
        ,isnull(datediff(mi,[a].[DEND],[b].[DBEG]),0) [PAUSE]
      from @EmployeeWorkPeriodsT [a]
        left join @EmployeeWorkPeriodsT [b] on [b].[WORKDAY]=[a].[WORKDAY] and [b].[DBEG]>=[a].[DEND]
      )
    insert into @EmployeeWorkPeriodsP
      select
         [a].[WORKDAY]
        ,[a].[DBEG]
        ,[a].[DEND]
        ,min([a].[PAUSE]) [PAUSE]
      from [T] [a]
      group by
         [a].[WORKDAY]
        ,[a].[DBEG]
        ,[a].[DEND]

    --select * from @EmployeeWorkPeriodsP

    update [a] set
      [a].[PAUSE_A]=[b].[PAUSE]
    from @EmployeeWorkDaysT [a]
      inner join
        (
        select
           [a].[WORKDAY]
          ,sum([a].[PAUSE]) [PAUSE]
        from @EmployeeWorkPeriodsP [a]
        group by [a].[WORKDAY]
        ) [b] on [a].[WORKDAY]=[b].[WORKDAY]
  end
  begin -- Fetching "vacation" records.
    declare @EmployeeVacationSourceG table(
       [ID] int identity,[DD] date,[WORKDAY] int,[DUR] float
      ,[TYPE] int
      ,[PERIOD] int  /* a2l:\\Link=doc.def_enumeration.127
                        0 : None
                        1 : Full
                        2 : Forenoon
                        3 : Afternoon
                      */
      ,[ABEG] datetime,[AEND] datetime
      ,[PAUSE] int,[EXTID] int,[WORK_PAUSE] int
      ,index [IX_1] ([WORKDAY])
      ,index [IX_2] clustered ([WORKDAY],[TYPE]))
    declare @EmployeeVacationSourceT table (
       [DD] date,[WORKDAY] int,[EXTID] int,[EMPID] int,[DBEG] date,[DEND] date,[DUR] float
      ,[TYPE] int,[TBEG] datetime,[TEND] datetime,[UNIT] char(1),[PERIOD] int
      ,index [IX_1] ([DBEG],[EMPID],[UNIT])
      ,index [IX_2] clustered ([DBEG],[DEND],[EMPID],[UNIT]));
    with [EMPLOYEE_VACATION] as
      (
      select
         [a].[ID] [VACID]
        ,[a].[EMPLID]
        ,[a].[DBEG]
        ,[a].[DEND]
        ,case when [a].[PERIODTYPE]=1    then 1.0
              when [a].[PERIODTYPE]=2    then 0.5
              when [a].[PERIODTYPE]=3    then 0.5
              when [a].[SHORTDURATION] is not null then round(cast([a].[SHORTDURATION] as float)/5.0,0)*5.0
         else (cast(datediff(day,[a].[DBEG],isnull([a].[DEND],[a].[DBEG])) as float) + 1) end [DUR]
        ,[a].[VACATIONTYPE] [TYPE]
        ,case when [a].[PERIODTYPE]   in (1,2,3)     then 'd'
              when [a].[VACATIONTYPE] in (30,80,200) then 'm'
              else 'd' end [UNIT]
        ,case when [a].[SHORTDURATION] is not null then cast(cast([a].[SHORTSTART] as time) as datetime)+cast([a].[DBEG] as datetime) end [TBEG]
        ,[a].[PERIODTYPE] [PERIOD]
      from [dbo].[COM_VACATION] [a] with(nolock)
        inner join @EmpT                       [b]              on ([b].[EMPID]=[a].[EMPLID])
        left  join [dbo].[COM_VACATION_CANCEL] [c] with(nolock) on ([c].[VACATIONID] = [a].[ID])
      where (([a].[S_S] in (1000141,2130051))               -- Approved or Submitted to HR
              or (([a].[S_S]=1000140) and (@IncludeUnapprovedLeaveOption=1))
              or (([a].[S_S]=1000147) and (@IncludeCanceledLeaveOption=1)))
        and ((isnull([c].[S_S],0) not in (1000160, 2130053)) or (@IncludeCanceledLeaveOption=1)) -- Cancelation is not "Approved" and not "Submitted to HR"
        and ([a].[DBEG] <= @DateEnd)
        and ((([a].[DBEG] >= @DateBeg) and ([a].[DEND] is null)) or (([a].[DEND] is not null) and ([a].[DEND] >= @DateBeg)))
      )
    insert into @EmployeeVacationSourceT
      select
         [b].[DD]
        ,[b].[WORKDAY]
        ,[a].[VACID]
        ,[a].[EMPLID]
        ,[a].[DBEG]
        ,isnull([a].[DEND],[a].[DBEG]) [DEND]
        ,[a].[DUR]
        ,[a].[TYPE]
        ,[a].[TBEG]
        ,case when [a].[TBEG] is not null then dateadd(minute,[a].[DUR],[a].[TBEG]) end [TEND]
        ,[a].[UNIT]
        ,[a].[PERIOD]
      from [EMPLOYEE_VACATION] [a]
        left join @EmployeeWorkDaysT [b] on ([b].[DD]=[a].[DBEG]) and ([b].[EMPID]=[a].[EMPLID]) and ([a].[UNIT]='m')

    -- Short absences
    insert into @EmployeeVacationSourceG
      select distinct
         [a].[DD]
        ,[a].[WORKDAY]
        ,datediff(minute,[o].[DBEG],[o].[DEND]) [DUR]
        ,[a].[TYPE]
        ,isnull([a].[PERIOD],0)
        ,[o].[DBEG]
        ,[o].[DEND]
        ,datediff(minute,[o].[DBEG],[o].[DEND]) [PAUSE]
        ,[a].[EXTID]
        ,0 [WORK_PAUSE]
      from @EmployeeVacationSourceT [a]
        left join @EmployeeWorkPeriodsP [c] on [c].[WORKDAY]=[a].[WORKDAY]
        cross apply [dbo].[COM_DATE_PERIOD_OVERLAP](
          [c].[DBEG],[c].[DEND],
          [a].[TBEG],[a].[TEND]) [o]
      --where [a].[TYPE]<>200

    ---- Kurzarbeit
    --insert into @EmployeeVacationSourceG
    --  select distinct
    --     [a].[DD]
    --    ,[a].[WORKDAY]
    --    ,[c].[BASEMINUTES] [DUR]
    --    ,[a].[TYPE]
    --    ,1 [PERIOD]
    --    ,[c].[DBEG]
    --    ,[c].[DEND]
    --    ,[c].[BASEMINUTES] [PAUSE]
    --    ,[a].[EXTID]
    --  from @EmployeeVacationSourceT [a]
    --    left join @EmployeeWorkDaysT [c] on [c].[WORKDAY]=[a].[WORKDAY]
    --  where [a].[TYPE]=200
    --    --and [a].[DUR]>=[c].[BASEMINUTES]

    --select * from @PersonalWorktimeG

    -- Long absences
    insert into @EmployeeVacationSourceG
      select distinct
         [b].[DD]
        ,[b].[WORKDAY]
        ,case
          when [b].[ISWORKDAY]=0 then 0
          when [a].[DUR]>1       then [c].[WORKMINUTES]
          when [a].[PERIOD]=2    then [c].[WORK_FORENOON]-[c].[PAUSE_FORENOON]
          when [a].[PERIOD]=3    then [c].[WORK_AFTRNOON]-[c].[PAUSE_AFTRNOON]
          else [a].[DUR]*[c].[WORKMINUTES] end [DUR]
        ,[a].[TYPE]
        ,[a].[PERIOD]
        ,case
          when [a].[PERIOD]=2 then dateadd(dd,[b].[OFFSET],[c].[TBEG])
          when [a].[PERIOD]=3 then dateadd(dd,[b].[OFFSET],[c].[TMID])
          else [a].[DBEG]
          end [DBEG]
        ,case
          when [a].[PERIOD]=2 then dateadd(dd,[b].[OFFSET],[c].[TMID])
          when [a].[PERIOD]=3 then dateadd(dd,[b].[OFFSET],[c].[TEND])
          else [a].[DEND]
          end [DEND]
        ,0 [PAUSE]
        ,[a].[EXTID]
        ,case
           when [a].[PERIOD]=2    then [c].[PAUSE_FORENOON]
           when [a].[PERIOD]=3    then [c].[PAUSE_AFTRNOON]
           else 0 end [WORK_PAUSE]
      from @EmployeeVacationSourceT [a]
        inner join @EmployeeWorkDaysT [b] on ([b].[DD]>=[a].[DBEG]) and ([b].[DD]<=[a].[DEND]) and ([b].[EMPID]=[a].[EMPID]) and ([a].[UNIT]='d')
        left  join @PersonalWorktimeG [c] on ([c].[EMPID]=[a].[EMPID]) and ([c].[WTID]=[b].[WTID]) and ([c].[SHIFT]=[b].[SHIFT])
      where [b].[ISWORKDAY]=1

    --select * from @EmployeeVacationSourceT
    --select * from @EmployeeVacationSourceG

    -- Deletes records whose values are less than another value for the same time (half a day)
    -- At the same time, we do not touch records with short absences
    delete [a] from @EmployeeVacationSourceG [a]
      inner join @EmployeeVacationSourceG [b] ON ([b].[WORKDAY]=[a].[WORKDAY]) and ([b].[ID]<>[a].[ID])
    where ([a].[DUR]<=[b].[DUR]) and not ([a].[TYPE] in (30,80,200))
      and ([a].[PERIOD] in (2,3)) and ([b].[PERIOD]=1)

    -- KB3853
    -- Deletes "sick leave" entries that have a regular vacation of the same duration at the same time
    delete [a] from @EmployeeVacationSourceG [a]
      inner join @EmployeeVacationSourceG [b] ON ([b].[WORKDAY]=[a].[WORKDAY]) and ([b].[ID]<>[a].[ID])
    where ([a].[DUR]=[b].[DUR]) 
      and ([b].[TYPE]= case when @DeleteVacationOnIntersectWithSickLeave = 1 then 20 else 10 end) /* KB5180  */
      and ([a].[TYPE]= case when @DeleteVacationOnIntersectWithSickLeave = 1 then 10 else 20 end) /* KB5180  */

	-- KB5448
    -- Deletes short vacation entries which intersect with sick leaves on the same day
	if (@DeleteVacationOnIntersectWithSickLeave = 1)
	begin
		delete [a] from @EmployeeVacationSourceG [a]
		  inner join @EmployeeVacationSourceG [b] ON ([b].[WORKDAY]=[a].[WORKDAY]) and ([b].[ID]<>[a].[ID])
		where [a].[TYPE]= 10
		  and [b].[TYPE]= 20
		  and [b].[DUR] = 480 -- full sick day
		  and [a].[DUR] < [b].[DUR]
	end

    --#region Deletes duplicated "sick leave" records
    delete [a] from @EmployeeVacationSourceG [a]
      inner join @EmployeeVacationSourceG [b] ON ([b].[WORKDAY]=[a].[WORKDAY]) and ([b].[ID]>[a].[ID])
    where [a].[DUR]=[b].[DUR]
      and [a].[TYPE]=20
      and [b].[TYPE]=20
    --#endregion
    --#region Deletes short entries that have sick leave for the same time
    delete [a] from @EmployeeVacationSourceG [a]
      inner join @EmployeeVacationSourceG [b] ON ([b].[WORKDAY]=[a].[WORKDAY]) and ([b].[ID]<>[a].[ID])
    where ([a].[DUR]<=[b].[DUR]) 
    and ([a].[TYPE] in (30))  /*KB4856*/
    and ([b].[TYPE]=20)
    --#endregion
    --#region Deletes all records with same period as "sick leave" but with other type
    delete [a] from @EmployeeVacationSourceG [a]
      inner join @EmployeeVacationSourceG [b] on [b].[WORKDAY]=[a].[WORKDAY]
    where [a].[TYPE]<>20
      and [b].[TYPE]=20
      and [a].[DUR]=[b].[DUR]
      and [a].[ABEG]=[b].[ABEG]
      and [a].[AEND]=[b].[AEND]
      and [a].[PERIOD]=[b].[PERIOD]
    --#endregion

    -- KB4763
    -- Deletes short entries that have a full vacation for the same time.
    delete [a] from @EmployeeVacationSourceG [a]
      inner join @EmployeeVacationSourceG [b] ON ([b].[WORKDAY]=[a].[WORKDAY]) and ([b].[ID]<>[a].[ID])
    where ([a].[DUR]<=[b].[DUR])
      and ([a].[TYPE] in (30))
      and ([b].[TYPE] in (10))
      and ([b].[PERIOD]=1)

    declare @EmployeeVacationD table ([WORKDAY] int,[FID] int,[LID] int,index [IX_1] clustered ([WORKDAY]))
    declare @EmployeeVacationSourceD table(
       [WORKDAY] int,[TYPE] int,[DUR] float
      ,[FBEG] datetime,[FEND] datetime  -- first absence in day
      ,[LBEG] datetime,[LEND] datetime  -- last  absence in day
      ,[WORK_PAUSE] float
      ,index [IX_1] clustered ([WORKDAY])
      ,index [IX_2] nonclustered ([WORKDAY],[TYPE]))
    insert into @EmployeeVacationSourceD([WORKDAY],[TYPE],[DUR],[WORK_PAUSE])
      select
         [a].[WORKDAY]
        ,[a].[TYPE]
        ,sum([a].[DUR]) [DUR]
        ,sum(isnull([a].[WORK_PAUSE],0)) [WORK_PAUSE]
      from @EmployeeVacationSourceG [a]
        inner join @EmployeeWorkDaysT [b] on [b].[WORKDAY]=[a].[WORKDAY]
      group by [a].[WORKDAY],[a].[TYPE]

    insert into @EmployeeVacationD
      select distinct
         [a].[WORKDAY]
        ,(select top 1 [b].[ID] from @EmployeeVacationSourceG [b] where [b].[WORKDAY]=[a].[WORKDAY] order by [b].[ABEG] asc ) [FID]
        ,(select top 1 [b].[ID] from @EmployeeVacationSourceG [b] where [b].[WORKDAY]=[a].[WORKDAY] order by [b].[ABEG] desc) [LID]
      from @EmployeeVacationSourceG [a]

    -- Deletes "Kurzarbeit" record if this day is full day vaction
    delete [a] from @EmployeeVacationSourceD [a]
      inner join @EmployeeVacationSourceD [b] on [b].[WORKDAY]=[a].[WORKDAY]
    where [a].[TYPE]=200
      and [b].[TYPE]=10
      and [a].[DUR]=[b].[DUR]

    -- KB5054
    -- Deletes "Kurzarbeit" record if this day is full sick
    delete [a] from @EmployeeVacationSourceD [a]
    where [a].[TYPE]=200
      and exists(select *
                 from @EmployeeVacationSourceD [b]
                   left join @EmployeeWorkDaysT [c] on [c].[WORKDAY]=[b].[WORKDAY]
                 where [b].[TYPE]=20
                   and [b].[WORKDAY]=[a].[WORKDAY]
                   and [b].[DUR]>=[c].[BASEMINUTES])

    update [a] set
       [a].[FBEG]=[f].[ABEG]
      ,[a].[FEND]=[f].[AEND]
      ,[a].[LBEG]=[l].[ABEG]
      ,[a].[LEND]=[l].[AEND]
    from @EmployeeVacationSourceD [a]
      inner join @EmployeeVacationD       [b] on [b].[WORKDAY]=[a].[WORKDAY]
      inner join @EmployeeVacationSourceG [f] on [f].[ID]=[b].[FID]
      inner join @EmployeeVacationSourceG [l] on [l].[ID]=[b].[LID]

   -- select * from @EmployeeVacationSourceD

    declare @EmployeeVacationSourceL table([WORKDAY] int
      ,[FBEG] datetime,[FEND] datetime  -- first absence in day
      ,[LBEG] datetime,[LEND] datetime  -- last  absence in day
      ,[DUR] float
      ,[WORK_PAUSE] float
      ,index [IX_1] ([WORKDAY])
      )
    insert into @EmployeeVacationSourceL
      select distinct
         [a].[WORKDAY]
        ,[a].[FBEG]
        ,[a].[FEND]
        ,[a].[LBEG]
        ,[a].[LEND]
        ,max([a].[DUR])
        ,max([a].[WORK_PAUSE])
      from @EmployeeVacationSourceD [a]
      group by
         [a].[WORKDAY]
        ,[a].[FBEG]
        ,[a].[FEND]
        ,[a].[LBEG]
        ,[a].[LEND]
  end

  --select * from @EmployeeWorkDaysT

  --#region [Vacations]
  --print N'Vacations...'
  insert into @Output([MARK],[KIND],[DD],[EMPID],[TYPE],[PERIOD],[DUR],[DBEG],[DEND],[ISWORKDAY],[DEPID],[WTID],[SHIFT],[EXTID],[EXTLB])
    select
      'vacationdetl'
      ,1
      ,[a].[DD]
      ,[b].[EMPID]
      ,[a].[TYPE]
      ,isnull([a].[PERIOD],0)
      ,[a].[DUR]
      ,case when [a].[TYPE]=10 and isnull([a].[PERIOD],0)=0 then [b].[DBEG] else [a].[ABEG] end
      ,case when [a].[TYPE]=10 and isnull([a].[PERIOD],0)=0 then [b].[DEND] else [a].[AEND] end
      ,[b].[ISWORKDAY]
      ,[b].[DEPID]
      ,[b].[WTID]
      ,[b].[SHIFT]
      ,[a].[EXTID]
      ,N'COM_VACATION'
    from @EmployeeVacationSourceG [a]
      inner join @EmployeeWorkDaysT [b] on [b].[WORKDAY]=[a].[WORKDAY]
  --#endregion
  --#region [Overtimes]
  --print N'Overtimes...'
  insert into @Output([MARK],[KIND],[DD],[EMPID],[TYPE],[DUR],[DBEG],[DEND],[ISWORKDAY],[DEPID],[WTID],[SHIFT],[EXTID],[EXTLB])
    select
      'overtimedetl'
      ,3
      ,[a].[DD]
      ,[a].[EMPID]
      ,[a].[TYPE]
      ,[a].[DUR]
      ,[a].[OBEG]
      ,[a].[OEND]
      ,[b].[ISWORKDAY]
      ,[b].[DEPID]
      ,[b].[WTID]
      ,[b].[SHIFT]
      ,[a].[EXTID]
      ,N'COM_ADDED_WORKTIME'
    from @EmplOvertimeA [a]
      inner join @EmployeeWorkDaysT [b] on [b].[WORKDAY]=[a].[WORKDAY]
  --#endregion
  --#region [Aggregate Vacations]
  --print N'Aggregate Vacations...'
  insert into @Output([MARK],[KIND],[DD],[EMPID],[TYPE],[DUR],[ISWORKDAY],[DEPID],[WTID],[SHIFT])
    select
      'vacationaggr'
      ,2
      ,[b].[DD]
      ,[b].[EMPID]
      ,[a].[TYPE]
      ,[a].[DUR]
      ,[b].[ISWORKDAY]
      ,[b].[DEPID]
      ,[b].[WTID]
      ,[b].[SHIFT]
    from @EmployeeVacationSourceD [a]
      inner join @EmployeeWorkDaysT [b] on [b].[WORKDAY]=[a].[WORKDAY]
  --#endregion

  --select * from @EmployeeVacationSourceL
  --select * from @EmployeeWorkDaysT

  --#region [Aggregate Overtimes]
  --print N'Aggregate Overtimes...'
  insert into @Output([MARK],[KIND],[DD],[EMPID],[TYPE],[DUR],[ISWORKDAY],[DEPID],[WTID],[SHIFT])
    select
      'overtimeaggr'
      ,4
      ,[b].[DD]
      ,[b].[EMPID]
      ,[a].[TYPE]
      ,[a].[DUR]
      ,[b].[ISWORKDAY]
      ,[b].[DEPID]
      ,[b].[WTID]
      ,[b].[SHIFT]
    from @EmplOvertimeG [a]
      inner join @EmployeeWorkDaysT [b] on [b].[WORKDAY]=[a].[WORKDAY]
  --#endregion
    --select * from @EmployeeWorkDaysT
    --print N'Aggregates'
    ;with [T]
    as
      (
      select
         [a].[DD]
        ,[a].[DEPID]
        ,[a].[EMPID]
        ,isnull((select [b].[DUR] from @EmployeeVacationSourceD [b] where ([b].[WORKDAY]=[a].[WORKDAY]) and ([b].[TYPE] =  30)),0.0) [A_SA]
        ,isnull((select [b].[DUR] from @EmployeeVacationSourceD [b] where ([b].[WORKDAY]=[a].[WORKDAY]) and ([b].[TYPE] = 200)),0.0) [A_KA]
        ,[a].[WORKDAY]
        ,[a].[WTID]
        ,[a].[SHIFT]
        ,[a].[BASEMINUTES]
        ,[a].[ISWORKDAY]
        ,[a].[OBEG]
        ,[a].[OEND]
        ,[a].[DBEG]
        ,[a].[DEND]
        ,[a].[PAUSE_A]
      from @EmployeeWorkDaysT [a]
      where ([a].[ISWORKDAY]=1) or ([a].[OBEG] is not null) or ([a].[OEND] is not null)
      )
    insert into @Output([MARK],[KIND],[DD],[DEPID],[EMPID],[WTID],[SHIFT],[DUR],[ISWORKDAY],[DBEG],[DEND],[PAUSE])
    select
       'dayaggregate'
      ,5
      ,[a].[DD]
      ,[a].[DEPID]
      ,[a].[EMPID]
      ,[a].[WTID]
      ,[a].[SHIFT]
      ,case when [a].[ISWORKDAY]=0 then 0 else [a].[BASEMINUTES] end [DUR]
      ,[a].[ISWORKDAY]
      ,[dbo].[COM_MIN_DATE](case when [a].[DBEG]=[c].[FBEG] and [a].[BASEMINUTES]>[c].[DUR] then [c].[FEND] else [a].[DBEG] end,[a].[OBEG]) [DBEG]
      ,[dbo].[COM_MAX_DATE](case when [a].[DEND]=[c].[LEND] and [a].[BASEMINUTES]>[c].[DUR] then [c].[LBEG] else [a].[DEND] end,[a].[OEND]) [DEND]
      ,[a].[PAUSE_A]+[a].[A_SA]-isnull([c].[WORK_PAUSE],0) [PAUSE]
    from [T] [a]
      left join @EmployeeVacationSourceL [c] on [c].[WORKDAY]=[a].[WORKDAY]

  insert into @Output([MARK],[KIND],[EMPID],[DUR],[WTID],[SHIFT],[EXTID],[EXTLB],[DBEG],[DEND])
    select
      'planworktime'
      ,6
      ,[a].[EMPID]
      ,[a].[WORKMINUTES]
      ,[a].[WTID]
      ,[a].[SHIFT]
      ,[a].[EXTID]
      ,N'COM_WORKTIME_BR'
      ,[a].[TBEG]
      ,[a].[TEND]
    from @PersonalWorktimeT [a]

  /*select
     [a].[WORKDAY]
    ,[a].[DBEG]
    ,[a].[DEND]
    ,[o].*
  from @EmployeeWorkPeriodsT [a]
    left join @EmployeeVacationSourceG [b] on [b].[WORKDAY]=[a].[WORKDAY]
                                          and [b].[TYPE] in (30)
                                          and [b].[ABEG]>=[a].[DBEG]
                                          and [b].[AEND]<=[a].[DEND]
    cross apply [dbo].[COM_DATE_PERIOD_SUBSTRACT](
          [a].[DBEG],[a].[DEND],
          [b].[ABEG],[b].[AEND]) [o]
  where datediff(mi,[o].[DBEG],[o].[DEND])>0
    --and ([a].[DBEG]<>[o].[DBEG] or [a].[DEND]<>[o].[DEND])
    */

  ;with [T] as
    (
    select distinct
       [a].[WORKDAY]
      ,[o].[DBEG]
      ,[o].[DEND]
      ,[a].[EXTID]
      ,[a].[EXTLB]
    from @EmployeeWorkPeriodsT [a]
      left join @EmployeeVacationSourceG [b] on [b].[WORKDAY]=[a].[WORKDAY]
                                            and [b].[TYPE] in (30)
                                            and [b].[ABEG]>=[a].[DBEG]
                                            and [b].[AEND]<=[a].[DEND]
      cross apply [dbo].[COM_DATE_PERIOD_SUBSTRACT](
            [a].[DBEG],[a].[DEND],
            [b].[ABEG],[b].[AEND]) [o]
    where datediff(mi,[o].[DBEG],[o].[DEND])>0
    )
  insert into @Output([MARK],[KIND],[DD],[EMPID],[DEPID],[DUR],[WTID],[SHIFT],[EXTID],[EXTLB],[DBEG],[DEND],[ISWORKDAY])
    select
      'actualwrktme'
      ,7
      ,[b].[DD]
      ,[b].[EMPID]
      ,[b].[DEPID]
      ,datediff(mi,[a].[DBEG],[a].[DEND])
      ,[b].[WTID]
      ,[b].[SHIFT]
      ,[a].[EXTID]
      ,[a].[EXTLB]
      ,[a].[DBEG]
      ,[a].[DEND]
      ,[b].[ISWORKDAY]
    from [T] [a]
      inner join @EmployeeWorkDaysT [b] on [b].[WORKDAY]=[a].[WORKDAY]
  --print N'Finish'
  return
end