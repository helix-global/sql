--KB5391: Using [PM_TASK_TIME].[MINUTES] if it available.
CREATE function [dbo].[PM_CALC_MATRIX_KB3897] (@aDepID int, @dbeg datetime, @dend datetime, @aMode int)
returns @res table (EMPLID int,PROJID int, TASKID int, MHOUR decimal(10,2),SOURCETYPE int)
as 
begin
  /*
  алгоритм в KB3897 
  */
  
  declare @dend2 datetime = @dend
  declare @now datetime = getdate()
  declare @nowd date = cast(@now as date)
  if @dend2 > @now
    set @dend2 = dateadd(day,1,@nowd)
  
  
  /*те, кто сейчас в отделе*/
  declare @empl table (ID int)
  insert into @empl (ID)
  select A.ID from COM_EMPLOYEE A with(nolock) where DEPID = @aDepID
  
  /*те, кто были в отделе в период @dbeg - @dend*/
  insert into @empl (ID)
  select A.EMPLID 
  from COM_EMPL_PERIODS A with(nolock) 
  where A.DEPID = @aDepID
    and not exists (select B.ID from @empl B where B.ID = A.EMPLID)
    and A.DBEG <= cast(@dend2 as date)
    and isnull(A.DEND,'40000101') >= cast(@dbeg as date)  
  
 declare @res2 table (EMPLID int,PROJID int, TASKID int, MHOUR decimal(10,2),SOURCETYPE int)
  
  /*
  Если проект принадлежит текущему отделу, то:
  Если проект имеет тип R&D, то достаточно указать только его ...
  */
  insert into @res2 (EMPLID,PROJID,TASKID,MHOUR,SOURCETYPE)
    select
       [a].EMPLID
      ,C.ID
      ,null
      ,(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)/60.0
      ,1
    from PM_TASK_TIME [a] with(nolock)
      left join PM_TASK B with(nolock) on B.ID = [a].TASKID
      left join PM_PROJECT C with(nolock) on C.ID = B.PROJID
    where [a].EMPLID in (select ID from @empl)
      and C.DEPID = @aDepID
      and [a].DD >= cast(@dbeg as date)
      and [a].DD <= cast(@dend2 as date) 
      and isnull(C.PTYPE,0) = 10 /* "Если проект имеет тип R&D" - ??????????? такого типа НЕТ!! Методом исключения возьмем "New Project" */

    
  /*
	Если проект принадлежит текущему отделу, то:
	Если проект другого типа, то находится задача, в которой произошла смена типа на R&D – именно она и указывается вместе с названием проекта. 
  */
  insert into @res2 (EMPLID,PROJID,TASKID,MHOUR,SOURCETYPE)
    select
       [a].EMPLID
      ,C.ID
      ,(select min(J.ID) from PM_TASK J with(nolock) where J.PROJID = C.ID and isnull(J.TASKTYPEOVERRIDE,0) = 10)
      ,(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)/60.0
      ,2
    from PM_TASK_TIME [a] with(nolock)
      left join PM_TASK B with(nolock) on B.ID = [a].TASKID
      left join PM_PROJECT C with(nolock) on C.ID = B.PROJID
    where [a].EMPLID in (select ID from @empl)
      and C.DEPID = @aDepID
      and [a].DD >= cast(@dbeg as date)
      and [a].DD <= cast(@dend2 as date) 
      and isnull(C.PTYPE,0) <> 10 
      and exists (select J.ID from PM_TASK J with(nolock) where J.PROJID = C.ID and isnull(J.TASKTYPEOVERRIDE,0) = 10)
      and dbo.PM_TASKTYPEFN2(B.TASKTYPEOVERRIDE,C.PTYPE,B.PARENTID) = 'R&D Task'
    
  /*
   Если проект принадлежит другому отделу, то указывается только задача, поступившая в отдел (если она имеет тип R&D,
    иначе ищется подзадача, на которой произошла смена типа задачи на R&D). 
  */  
  insert into @res2 (EMPLID,PROJID,TASKID,MHOUR,SOURCETYPE)
    select
       [a].EMPLID
      ,C.ID
      ,(select min(J.ID) from PM_TASK J with(nolock) where J.PROJID = C.ID and J.RESPDEP = @aDepID and isnull(J.TASKTYPEOVERRIDE,0) = 10)
      ,(case when [a].[MINUTES] is not null then [a].[MINUTES] else round([a].[MHOUR]*60,0) end)/60.0
      ,3
    from PM_TASK_TIME [a] with(nolock)
      left join PM_TASK B with(nolock) on B.ID = [a].TASKID
      left join PM_PROJECT C with(nolock) on C.ID = B.PROJID
    where [a].EMPLID in (select ID from @empl)
      and C.DEPID <> @aDepID
      and [a].DD >= cast(@dbeg as date)
      and [a].DD <= cast(@dend2 as date) 
      and exists (select J.ID from PM_TASK J with(nolock) where J.PROJID = C.ID and J.RESPDEP = @aDepID and isnull(J.TASKTYPEOVERRIDE,0) = 10)
      and dbo.PM_TASKTYPEFN2(B.TASKTYPEOVERRIDE,C.PTYPE,B.PARENTID) = 'R&D Task'

  insert into @res (EMPLID,PROJID,TASKID,SOURCETYPE,MHOUR)
  select A.EMPLID,A.PROJID,A.TASKID,A.SOURCETYPE,SUM(A.MHOUR)
  from @res2 A
  group by A.EMPLID,A.PROJID,A.TASKID,A.SOURCETYPE

  
  return

end