-- KB5391:2025-04-28: Using [PM_TASK_TIME].[MINUTES] if it available.
CREATE function [dbo].[PM_COEFF_UNPLANNED_WORK] (@EmplID int, @dbeg date, @dend date)
returns @res table (X1 decimal(16,4),X2 decimal(16,4),X3 decimal(16,4),Wt decimal(16,4),Rt decimal(16,4),Pt decimal(16,4))
as 
begin
  /*KB2974*/

  declare @X1 decimal(16,4)
  declare @X2 decimal(16,4)
  declare @X3 decimal(16,4)

  declare @Rt decimal(16,4)
  declare @Wt decimal(16,4)
  declare @Pt decimal(16,4)

  declare @WhID int
  declare @Calendar int

  select
    @Wt = sum([dbo].[COM_WORK_MINUTS6]([DDATE],[DDATE_PLUS1],[WHID],[CALENDAR],@EmplID))
  from (
    select
       [DDATE]
      ,[DDATE_PLUS1]
      ,[WHID]
      ,(select [time].[CALENDAR] from [dbo].[COM_WORKTIME] [time] with(nolock) where [time].[ID] = [WHID]) as [CALENDAR]
    from (
      select
         [a].[DDATE]
        ,[a].[DDATE_PLUS1]
        ,[dbo].[COM_WORKTABLE_BY_DATE2]([a].[DDATE],@EmplID) as [WHID]
      from [dbo].[COM_DAY_PERIOD2](@dbeg,@dend) [a]
    ) [M]
    ) [M2]

  set @Wt = @Wt / 60

  if @Wt = 0
    return

  select
    @Rt = sum(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)/60.0
  from [dbo].[PM_TASK_TIME] [a] with(nolock)
  where [a].[EMPLID] = @EmplID
    and [a].[DD] >= @dbeg
    and [a].[DD] <= @dend
    and exists (select [j].[ID]
                from [dbo].[PM_DEV_PLAN_T] [j] with(nolock)
                  left join [dbo].[PM_DEV_PLAN] [k] with(nolock) on [k].[ID]=[j].[VNESHID]
                where [j].[TASKID]=[a].[TASKID]
                  and [k].[EMPLID] = @EmplID /*? в ТЗ имеется в виду только свои планы или любые ?*/
               )

  set @X1 = (1-@Rt/@Wt)*100

  /*
  здесь есть принципиальная проблема ТЗ: 
  в разных планах одна и та же задача м.б. по-разному распределена по датам
  и если период пересекает несколько планов то возникает неопределенность 
  + старые планы неизвестно когда в истории действовали и действовали ли вообще
  */

  declare @CurrentPlan int

  select top 1
    @CurrentPlan = [plan].[ID]
  from [dbo].[PM_DEV_PLAN] [plan] with(nolock)
  where [plan].[EMPLID] = @EmplID
    and [plan].[S_S] = 2130057/*approved*/
  order by [plan].[ID] desc

  select
    @Pt = sum([a].[MHOUR])
  from [dbo].[PM_DEV_PLAN_T_T] [a] with(nolock)
    left join [dbo].[PM_DEV_PLAN_T] [b] with(nolock) on [b].[ID]=[a].[VNESHID]
    left join [dbo].[PM_DEV_PLAN]   [c] with(nolock) on [c].[ID]=[b].[VNESHID]
  where [c].[ID] = @CurrentPlan
    and [a].[DD] >= @dbeg
    and [a].[DD] <= @dend

  if @Pt > 0
  begin
    set @X2 = 1-(@Rt/@Pt)
  end

  declare @ByTasks table([TASKID] int,[RT] decimal(16,4),[PT] decimal(16,5),[A] decimal(16,5))
  insert into @ByTasks([TASKID],[PT])
    select
       [b].[TASKID]
      ,sum([a].[MHOUR])
    from [dbo].[PM_DEV_PLAN_T_T] [a] with(nolock)
      left join [dbo].[PM_DEV_PLAN_T] [b] with(nolock) on [b].[ID]=[a].[VNESHID]
    where [b].[VNESHID] = @CurrentPlan
      and [a].[DD] >= @dbeg
      and [a].[DD] <= @dend
    group by [b].[TASKID]

  update [a] set
    RT = (select sum(case when [G].[MINUTES] is not null then [G].[MINUTES] else round([G].[MHOUR]*60,0) end)/60.0
          from [dbo].[PM_TASK_TIME] [G] with(nolock)
          where [G].[TASKID]=[a].[TASKID]
            and [G].[EMPLID] = @EmplID)
  from @ByTasks [a]

  update [a] set
    [a].[A] = [RT]/[PT]
  from @ByTasks [a]
  where [PT] <> 0

  select @X3 = sqrt(sum((1-A)*(1-A))/count(1)) from @ByTasks
  insert into @res (X1,X2,X3,Wt,Rt,Pt) values (@X1,@X2,@X3,@Wt,@Rt,@Pt)
  return
end