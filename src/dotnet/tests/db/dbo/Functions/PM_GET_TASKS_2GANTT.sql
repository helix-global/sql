-- KB5391:2025-04-28: Using [PM_TASK_TIME].[MINUTES] if it available.
CREATE function [dbo].[PM_GET_TASKS_2GANTT] (@aProjID int, @aMode int)
returns @res table (ID int,PARENTID int,DBEG datetime,DEND datetime,LABOR_EST decimal(10,2),LABOR_FACT decimal(10,2))
as 
begin
  
  insert into @res (ID,PARENTID,DBEG,DEND,LABOR_EST,LABOR_FACT)
  select A.ID
      ,A.PARENTID
	  ,isnull(A.DBEG,A.DD) as DBEG
	  ,coalesce(A.CLODEDATE,A.DUEDATE,dateadd(hour,isnull(A.LABOR_EST,24),isnull(A.DBEG,A.DD))) as DEND	  
	  ,A.LABOR_EST
	  ,(select sum(case when [b].[MINUTES] is not null then [b].[MINUTES] else round([b].[MHOUR]*60,0) end)/60.0 from PM_TASK_TIME [b] with (nolock) where [b].TASKID = A.ID)
  from PM_TASK A with (nolock)
  where A.PROJID = @aProjID
  
  /*
  update @res set DBEG = null, DEND = null where exists(select G.ID from @res G where G.PARENTID = "@res".ID)
  */
 
  declare @i int = 0
  while @i < 30
  begin
  
    update @res set 
      DBEG = (select min(J.DBEG) from @res J where J.PARENTID = "@res".ID)
     ,DEND = (select max(K.DEND) from @res K where K.PARENTID = "@res".ID)
     ,LABOR_EST = (select sum(L.LABOR_EST) from @res L where L.PARENTID = "@res".ID)
     ,LABOR_FACT = (select sum(L.LABOR_FACT) from @res L where L.PARENTID = "@res".ID)
    where exists(select G.ID from @res G where G.PARENTID = "@res".ID)
  
    set @i = @i + 1
  end 
  
  return

end