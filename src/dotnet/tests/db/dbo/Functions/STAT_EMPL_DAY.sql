-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2023-12-21
-- Description: Retrieving employee statistics for the specified period.
-- =============================================
-- KB4992:2024-10-07: Updated to use [STAT_EMPL_PERSONAL_WORKTIME] function.
-- KB4903:2024-07-29: Fixed overtime and worktime intersections {Dmitrii Maistrenko}
-- KB4763:2024-05-06: Fixed an issue with short entries having a full vacation for the same time.
-- KB4754:2024-04-26: Obtaining a work shift from "kurzarbeit" records, if the shift is not explicitly recorded.
-- KB4700:2024-04-19: Fixed overtime and absence records intersections. Additional fields for time-sheet reporting.
-- KB4732:2024-04-15: Fixed "violation of UNIQUE KEY constraint" error.
-- KB4651:2024-04-12: Added additional fields for overtime, work schedule, work hours and "Kurzarbeit" hours {Dmitrii Maistrenko}.
-- KB4582:2024-02-09: Fixed employee period intersections {Dmitrii Maistrenko}
-- KB4582:2024-02-08: Fixed duplicated record issue for ([DD]=2023-07-31,[EMPID]=3220) {Dmitrii Maistrenko}
--       :2023-12-21: Initial update.
CREATE FUNCTION [dbo].[STAT_EMPL_DAY](
  @DateBeg date,
  @DateEnd date,
  @DepId int,
  @EmpId int,
  @Options nvarchar(max))
returns
  @OutputT table (
     [DD] date,[ISWORKDAY] int,[DEPID] int,[EMPID] int,[WTID] int,[SHIFT] int
    ,[DBEG] datetime,[DEND] datetime
    ,[B] float
    ,[A_VA] float,[A_SI] float,[A_SA] float,[A_UL] float,[A_BT] float
    ,[A_TR] float,[A_SP] float,[A_IA] float,[A_PL] float,[A_CC] float
    ,[A_KA] float
    ,[A_DT_VA] varchar(max),[A_DT_SI] varchar(max),[A_DT_SA] varchar(max),[A_DT_UL] varchar(max),[A_DT_BT] varchar(max)
    ,[A_DT_TR] varchar(max),[A_DT_SP] varchar(max),[A_DT_IA] varchar(max),[A_DT_PL] varchar(max),[A_DT_CC] varchar(max)
    ,[A_DT_KA] varchar(max)
    ,[O_OT] float,[O_TA] float
    ,[PAUSE] float
    ,unique clustered ([DD],[EMPID]))
as
begin
  declare @IncludeVactionDetail int = 0
  declare @OptionsT table ([OPTION] nvarchar(max))
  declare @StatT table(
    [MARK] varchar(32),[KIND] int,[DD] date,[ISWORKDAY] int,[DEPID] int,
    [EMPID] int,[TYPE] int,[PERIOD] int,[DUR] int,[PAUSE] int,
    [DBEG] datetime,[DEND] datetime,
    [WTID] int,[SHIFT] int,[EXTID] int,[EXTLB] nvarchar(256)
    ,index [IX-1] ([KIND])
    ,index [IX-2] ([DD],[KIND])
    ,index [IX-3] clustered ([KIND],[DD],[EMPID],[TYPE]))

  insert into @OptionsT select [ITEM] from [dbo].[COM_STR2TABLE_STR](@Options)
  if exists(select * from @OptionsT where [OPTION] like 'IncludeVactionDetail')  set @IncludeVactionDetail = 1

  insert into @StatT([MARK],[KIND],[DD],[ISWORKDAY],[DEPID],[EMPID],[TYPE],[PERIOD],[DUR],[PAUSE],[DBEG],[DEND],[WTID],[SHIFT],[EXTID],[EXTLB])
    select
       [a].[MARK]
      ,[a].[KIND]
      ,[a].[DD]
      ,[a].[ISWORKDAY]
      ,[a].[DEPID]
      ,[a].[EMPID]
      ,[a].[TYPE]
      ,[a].[PERIOD]
      ,[a].[DUR]
      ,[a].[PAUSE]
      ,[a].[DBEG]
      ,[a].[DEND]
      ,[a].[WTID]
      ,[a].[SHIFT]
      ,[a].[EXTID]
      ,[a].[EXTLB]
    from [dbo].[STAT_EMPL_PERSONAL_WORKTIME](@DateBeg,@DateEnd,@DepId,@EmpId,@Options) [a]

  --  10 VA: Vacation
  --  20 SI: Sick Leave
  --  30 SA: Short Absence
  --  15 UL: Unpaid Leave
  --  50 BT: Business Trip
  --  60 TR: Training
  --  70 SP: Special Leave
  --  80 IA: Internal Appointment
  --  90 PL: Parental Leave
  -- 100 CC: Child Care
  -- 200 KA: Kurzarbeit

  --select * from @StatT [a] where [a].[KIND]=1

  if @IncludeVactionDetail=1
  begin
    insert into @OutputT([DD],[ISWORKDAY],[DEPID],[EMPID],[WTID],[SHIFT],[DBEG],[DEND],[B],
          [A_VA],[A_SI],[A_SA],[A_UL],[A_BT],
          [A_TR],[A_SP],[A_IA],[A_PL],[A_CC],
          [A_KA],[O_OT],[O_TA],[PAUSE],
          [A_DT_VA],[A_DT_SI],[A_DT_SA],[A_DT_UL],
          [A_DT_BT],[A_DT_TR],[A_DT_SP],[A_DT_IA],
          [A_DT_PL],[A_DT_CC],[A_DT_KA])
      select
         [a].[DD]
        ,[a].[ISWORKDAY]
        ,[a].[DEPID]
        ,[a].[EMPID]
        ,[a].[WTID]
        ,[a].[SHIFT]
        ,[a].[DBEG]
        ,[a].[DEND]
        ,[a].[DUR]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 10),0) [A_VA]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 20),0) [A_SI]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 30),0) [A_SA]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 15),0) [A_UL]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 50),0) [A_BT]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 60),0) [A_TR]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 70),0) [A_SP]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 80),0) [A_IA]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 90),0) [A_PL]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=100),0) [A_CC]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=200),0) [A_KA]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=4 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=  1),0) [O_OT]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=4 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=  2),0) [O_TA]
        ,[a].[PAUSE]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=10 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=10 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=10 and [b].[PERIOD]=3
          ) [b]) [A_DT_VA]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=20 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=20 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=20 and [b].[PERIOD]=3
          ) [b]) [A_DT_SI]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=30 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=30 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=30 and [b].[PERIOD]=3
          ) [b]) [A_DT_SA]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=15 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=15 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=15 and [b].[PERIOD]=3
          ) [b]) [A_DT_UL]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=50 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=50 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=50 and [b].[PERIOD]=3
          ) [b]) [A_DT_BT]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=60 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=60 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=60 and [b].[PERIOD]=3
          ) [b]) [A_DT_TR]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=70 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=70 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=70 and [b].[PERIOD]=3
          ) [b]) [A_DT_SP]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=80 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=80 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=80 and [b].[PERIOD]=3
          ) [b]) [A_DT_IA]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=90 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=90 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=90 and [b].[PERIOD]=3
          ) [b]) [A_DT_PL]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=100 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=100 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=100 and [b].[PERIOD]=3
          ) [b]) [A_DT_CC]
        ,(select [dbo].[GROUP_CONCAT_D]([DESC],',')
         from
          (
           select top 1 'Full'     [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=200 and [b].[DUR]>=[a].[DUR] union all
           select top 1 'Forenoon' [DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=200 and [b].[PERIOD]=2 union all
           select top 1 'Afternoon'[DESC] from @StatT [b] where [b].[KIND]=1 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=200 and [b].[PERIOD]=3
          ) [b]) [A_DT_KA]
      from @StatT [a]
      where [a].[KIND]=5
  end
  else
  begin
    insert into @OutputT([DD],[ISWORKDAY],[DEPID],[EMPID],[WTID],[SHIFT],[DBEG],[DEND],[B],
          [A_VA],[A_SI],[A_SA],[A_UL],[A_BT],
          [A_TR],[A_SP],[A_IA],[A_PL],[A_CC],
          [A_KA],[O_OT],[O_TA],[PAUSE])
      select
         [a].[DD]
        ,[a].[ISWORKDAY]
        ,[a].[DEPID]
        ,[a].[EMPID]
        ,[a].[WTID]
        ,[a].[SHIFT]
        ,[a].[DBEG]
        ,[a].[DEND]
        ,[a].[DUR]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 10),0) [A_VA]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 20),0) [A_SI]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 30),0) [A_SA]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 15),0) [A_UL]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 50),0) [A_BT]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 60),0) [A_TR]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 70),0) [A_SP]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 80),0) [A_IA]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]= 90),0) [A_PL]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=100),0) [A_CC]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=2 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=200),0) [A_KA]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=4 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=  1),0) [O_OT]
        ,isnull((select top 1 [b].[DUR] from @StatT [b] where [b].[KIND]=4 and [b].[DD]=[a].[DD] and [b].[EMPID]=[a].[EMPID] and [b].[TYPE]=  2),0) [O_TA]
        ,[a].[PAUSE]
      from @StatT [a]
      where [a].[KIND]=5
  end
  return
  --select * from @OUTPUT
end