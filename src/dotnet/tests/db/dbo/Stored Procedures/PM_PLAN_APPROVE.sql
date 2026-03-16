CREATE PROCEDURE [dbo].[PM_PLAN_APPROVE] @PlanID int, @UserID int, @aMode int
AS
BEGIN
  set nocount on

  declare @now datetime
  set @now = GETDATE()


  update PM_TASK set 
     LABOR_EST = (select B.LABOR_EST from PM_DEV_PLAN_T B where B.VNESHID = @PlanID and B.TASKID = PM_TASK.ID)
    ,LASTPLAN_ROWID = (select B.ID from PM_DEV_PLAN_T B where B.VNESHID = @PlanID and B.TASKID = PM_TASK.ID) 
    ,DBEG = (select isnull(min(C.DD),PM_TASK.DBEG) 
               from PM_DEV_PLAN_T B 
               left join PM_DEV_PLAN_T_T C on C.VNESHID = B.ID
              where B.VNESHID = @PlanID 
                and B.TASKID = PM_TASK.ID
                and C.DD is not null)
                /*
    ,PLANDATE = (select isnull(max(C.DD),PM_TASK.PLANDATE)
               from PM_DEV_PLAN_T B 
               left join PM_DEV_PLAN_T_T C on C.VNESHID = B.ID
              where B.VNESHID = @PlanID 
                and B.TASKID = PM_TASK.ID
                and C.DD is not null)
                */
    ,PLANDATE = dbo.PM_TASK_NEWPLANDATE(PM_TASK.PLANDATE,@PlanID,PM_TASK.ID,0)  /*KB3554 п.4*/
  where PM_TASK.ID in (select K.TASKID from PM_DEV_PLAN_T K where K.VNESHID = @PlanID)
  

  insert into PM_TASK_PLAN_HISTORY(TASKID,DD,PLANID,LABOR_EST,DBEG,DEND)
  select TASKID,DD,VNESHID,LABOR_EST,DBEG,DEND
  from (
	  select A.TASKID,getdate() as DD,A.VNESHID,A.LABOR_EST
	   ,(select min(C.DD) from PM_DEV_PLAN_T_T C where C.VNESHID = A.ID and C.DD is not null) as DBEG
	   ,(select max(C.DD) from PM_DEV_PLAN_T_T C where C.VNESHID = A.ID and C.DD is not null) as DEND
	  from PM_DEV_PLAN_T A 
	  where A.VNESHID = @PlanID
  ) M
  where M.LABOR_EST is not null or M.DBEG is not null or M.DEND is not null
  
  /*по родительским задачам обновление дат и labor */
  /* 1 список родительских задач, у которых в дочерних есть задачи из @PlanID*/
  declare @parents table (ID int not null primary key, UPDATED int)
  declare @i int = 0  
  
  insert into @parents (ID,UPDATED)
  select distinct A.PARENTID,0 
  from PM_TASK A with (nolock)
  where A.ID in (select K.TASKID from PM_DEV_PLAN_T K where K.VNESHID = @PlanID)
    and A.PARENTID is not null
    
  update PM_TASK set 
   LABOR_EST = (select sum(isnull(B.LABOR_EST,0)) from PM_TASK B with (nolock) where B.PARENTID = PM_TASK.ID and B.LABOR_EST is not null)
  ,DBEG = (select min(B.DBEG) from PM_TASK B with (nolock) where B.PARENTID = PM_TASK.ID and B.DBEG is not null)
  ,PLANDATE = (select max(B.PLANDATE) from PM_TASK B with (nolock) where B.PARENTID = PM_TASK.ID and B.PLANDATE is not null)
  where PM_TASK.ID in (select G.ID from @parents G where G.UPDATED = 0)
  
  update @parents set UPDATED = 1
    
  while @i < 100
  begin
  
    insert into @parents (ID,UPDATED)
    select distinct A.PARENTID,0 
      from PM_TASK A with (nolock)
     where A.ID in (select ID from @parents) 
       and not exists (select G.ID from @parents G where G.ID = A.PARENTID)
       and A.PARENTID is not null

    if @@ROWCOUNT = 0
      break 
      
    update PM_TASK set 
	   LABOR_EST = (select sum(isnull(B.LABOR_EST,0)) from PM_TASK B with (nolock) where B.PARENTID = PM_TASK.ID and B.LABOR_EST is not null)
	  ,DBEG = (select min(B.DBEG) from PM_TASK B with (nolock) where B.PARENTID = PM_TASK.ID and B.DBEG is not null)
	  ,PLANDATE = (select max(B.PLANDATE) from PM_TASK B with (nolock) where B.PARENTID = PM_TASK.ID and B.PLANDATE is not null)
    where PM_TASK.ID in (select G.ID from @parents G where G.UPDATED = 0)
  
    update @parents set UPDATED = 1 where UPDATED = 0
   
    set @i = @i + 1
     
  end 
  
  /*KB2974*/
  declare @prevPlan int
  declare @emplid int
  declare @dd datetime
  select @emplid = A.EMPLID,@dd = A.DD from PM_DEV_PLAN A where A.ID = @PlanID
  select top 1 @prevPlan = A.ID from PM_DEV_PLAN A where A.EMPLID = @emplid and A.DD < @dd and A.ID <> @PlanID order by A.DD desc, A.ID desc
  update PM_DEV_PLAN set S_S = 2130059/*deprecated*/ where ID = @prevPlan
  
  /*KB3503  ? что такое "старый" план ? любой ранее утвержденный ? */
  update PM_DEV_PLAN set S_S = 2130059/*deprecated*/ where ID <> @PlanID and S_S = 2130057/*approved*/ and EMPLID = @emplid

END