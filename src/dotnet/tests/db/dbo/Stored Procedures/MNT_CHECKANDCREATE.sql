CREATE procedure [dbo].[MNT_CHECKANDCREATE]
as 
SET nocount on

update MNT_PLAN set NEXTDATE = dbo.MNT_NEXT_SNOOZE(ID) where NEXTDATE is null and S_S = 1

declare @now datetime
set @now = GETDATE()

if exists(select A.ID from MNT_PLAN A with (nolock) where A.NEXTDATE <= @now and A.S_S = 1)
BEGIN
  declare @needUpdate table (ID int not null)
  insert into @needUpdate (ID) 
  select A.ID from MNT_PLAN A where A.NEXTDATE <= @now   and A.S_S = 1

  declare @newOperations table (OPERTYPE int,USERID int,MNT_PLANID int,MNTPLAN_S_CR int,MNT_HIGHPR datetime,TODOTEXT ntext,EQID int)

  /* mode 1 */   
  insert into @newOperations(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT)
  select A.OPERID,null,A.ID,A.S_CR,dbo.MNT_HIGHPRDATETIME(@now,A.HP_DAY,A.HP_HOUR,A.HP_MINUTE),A.TODO
    from MNT_PLAN A 
   where A.ID in (select G.ID from @needUpdate G)
     and isnull(A.CRMODE,0) = 1
  
  /* mode 2 */
  insert into @newOperations(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT)
  select A.OPERID,D.ID,A.ID,A.S_CR,dbo.MNT_HIGHPRDATETIME(@now,A.HP_DAY,A.HP_HOUR,A.HP_MINUTE),A.TODO
    from MNT_PLAN A 
    left join PR_OPERATIONS B on B.ID = A.OPERID
    left join PR_EMPL_TO_OPERGR C on C.GROUPID = B.OPERGRID
    left join DEF_USERS D on D.EMPLOYEEID = C.EMPLOYEEID
    left join COM_EMPLOYEE E on E.ID = C.EMPLOYEEID
   where A.ID in (select G.ID from @needUpdate G)
     and isnull(A.CRMODE,0) = 2
     and E.S_S = 1
     and isnull(C.DBEG,'19900101') <= @now and isnull(C.DEND,'40000101') >= @now
  
  /* mode 3 */
  insert into @newOperations(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT,EQID)
  select A.OPERID,null,A.ID,A.S_CR,dbo.MNT_HIGHPRDATETIME(@now,A.HP_DAY,A.HP_HOUR,A.HP_MINUTE),A.TODO,C.ID
    from MNT_PLAN A 
    left join MNT_PLAN_EQ B on B.VNESHID = A.ID
    left join EQ_EQUIPMENT C on C.ID = B.EQID
   where A.ID in (select G.ID from @needUpdate G)
     and isnull(A.CRMODE,0) = 3
     /*and C.S_S = 1000173*/ /*in use*/
     and dbo.MNT_EQ_EXEC_STATE_CHECK(C.S_S,A.EXEC_EQ_STATES) = 1  /*KB3303*/

  /* mode 4 */
  insert into @newOperations(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT,EQID)
  select A.OPERID,D.ID,A.ID,A.S_CR,dbo.MNT_HIGHPRDATETIME(@now,A.HP_DAY,A.HP_HOUR,A.HP_MINUTE),A.TODO,C.ID
    from MNT_PLAN A 
    left join MNT_PLAN_EQ B on B.VNESHID = A.ID
    left join EQ_EQUIPMENT C on C.ID = B.EQID
    left join DEF_USERS D on D.EMPLOYEEID = C.RESP_EMPLID
   where A.ID in (select G.ID from @needUpdate G)
     and isnull(A.CRMODE,0) = 4
     /*and C.S_S = 1000173 *//*in use*/
     and dbo.MNT_EQ_EXEC_STATE_CHECK(C.S_S,A.EXEC_EQ_STATES) = 1  /*KB3303*/
     

  insert into PR_OPERATION (GID,S_S,OPERTYPEID,S_CDT,S_CR,USERINPROGRESS,TODOTEXT,MNT_PLANID,HIGHPRDATE,URGENCY,EQID)
  select newid(),1000032,A.OPERTYPE,@now,A.MNTPLAN_S_CR,A.USERID,A.TODOTEXT,MNT_PLANID,MNT_HIGHPR,2,EQID
  from @newOperations A 
  
  update MNT_PLAN set NEXTDATE = dbo.MNT_NEXT_SNOOZE(ID) where ID in (select B.ID from @needUpdate B)

END

if exists (select A.ID from PR_OPERATION A where A.MNT_PLANID is not null and A.HIGHPRDATE <= @now and isnull(A.URGENCY,0) < 10)
BEGIN

  update PR_OPERATION set URGENCY = 10 where MNT_PLANID is not null and HIGHPRDATE <= @now and isnull(URGENCY,0) < 10

END


set nocount off