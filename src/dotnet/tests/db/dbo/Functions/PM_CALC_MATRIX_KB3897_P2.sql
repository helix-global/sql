--KB5391: Using [PM_TASK_TIME].[MINUTES] if it available.
CREATE function [dbo].[PM_CALC_MATRIX_KB3897_P2] (@aDepID int, @dbeg datetime, @dend datetime, @aMode int)
returns @res table (EMPLID int, ALLHOURS decimal(12,2), VACATIONS decimal(12,2), RADND decimal(10,2), OTHER decimal(10,2), ALLTRACKED decimal(15,2))
as 
begin
  /*
  алгоритм KB3897 часть 2
  */
  
  declare @dend2 datetime = @dend
  declare @now datetime = getdate()
  declare @nowd date = cast(@now as date)
  if @dend2 > @now
    set @dend2 = dateadd(day,1,@nowd)
  
  /*те, кто сейчас в отделе*/
  declare @empl table (ID int)

  insert into @empl (ID)
  select distinct E.ID
  from COM_EMPLOYEE E with(nolock)
  left join COM_EMPL_PERIODS P with(nolock) on P.EMPLID=E.ID and P.DEPID = @aDepID
    where (P.ID is not null or E.DEPID = @aDepID)
    and exists (select * from dbo.COM_EMPLOYEE_IN_DEP_RANGE(E.ID, @aDepID, @dbeg, @dend2, 1))

/*
  delete from @empl
  insert into @empl (ID) values (1885)
  insert into @empl (ID) values (1887)
*/
  insert into @res (EMPLID,ALLHOURS)
  select A.ID
     ,dbo.COM_WORK_MINUTS_BY_DEP2(@aDepID,@dbeg,@dend2,1,A.ID,0)
  from COM_EMPLOYEE A with(nolock)
  where A.ID in (select ID from @empl)
  
  declare @vacations table (EMPLID int,RES decimal(18,2)) 
  insert into @vacations (EMPLID,RES)
    select A.EMPLID,sum(C.MINUTES)
    from COM_VACATION A with (nolock)
    outer apply dbo.COM_VACATION_MINUTES_BYDAYS2(A.ID) C
    where A.EMPLID in (select ID from @empl)
      and A.S_S in( 1000141,2130051)
      and isnull(A.DEND,A.DBEG) >= @dbeg
      and dbo.COM_VACATION_OVERRIDE(A.ID,A.EMPLID,1) = 0  /*KB2254*/
      and A.DBEG <= @dend2
      and C.DD is not null
      and C.DD <= @dend2
      and C.DD >= @dbeg
      and dbo.COM_EMPLOYEE_IN_DEP(A.EMPLID, @aDepID, cast(C.DD as datetime))=1
    group by A.EMPLID
  
  update @res set VACATIONS = (select sum(RES) from @vacations B where B.EMPLID = "@res".EMPLID)
  
  declare @dataFromFirstPart table (EMPLID int, RES decimal(15,2))
  insert into @dataFromFirstPart(EMPLID, RES)
  select A.EMPLID,sum(A.MHOUR)
  from dbo.PM_CALC_MATRIX_KB3897 (@aDepID, @dbeg, @dend2, 0) A
  group by A.EMPLID
  
  update @res set RADND = (select sum(A.RES) from  @dataFromFirstPart A where A.EMPLID = "@res".EMPLID)

  update @res set ALLTRACKED = (select sum(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)/60.0
                           from PM_TASK_TIME [a] with(nolock)
                            left join PM_TASK B with(nolock) on B.ID = [a].TASKID
                            left join PM_PROJECT C with(nolock) on C.ID = B.PROJID
                           where [a].EMPLID = "@res".EMPLID
                             and [a].DD >= @dbeg
                             and [a].DD <= @dend2
                           )   
  
  update @res set OTHER = (select sum(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)/60.0
                           from PM_TASK_TIME [a] with(nolock)
                            left join PM_TASK B with(nolock) on B.ID = [a].TASKID
                            left join PM_PROJECT C with(nolock) on C.ID = B.PROJID
                           where [a].EMPLID = "@res".EMPLID
                             and [a].DD >= @dbeg
                             and [a].DD <= @dend2
                             and dbo.PM_TASKTYPEFN2(B.TASKTYPEOVERRIDE,C.PTYPE,B.PARENTID) = 'Other'
                           )  
  
  
  return

end