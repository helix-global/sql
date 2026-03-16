CREATE procedure [dbo].[MNT_CHECKANDCREATE2]
as 
SET nocount on

update MNT_PLAN set NEXTDATE = dbo.MNT_NEXT_SNOOZE2(ID,null) where NEXTDATE is null and S_S = 1 and CRMODE in (1,2)

declare @now datetime
set @now = GETDATE()

if exists(select A.ID from MNT_PLAN A with (nolock) where A.NEXTDATE <= @now and A.S_S = 1 and A.CRMODE in (1,2))
BEGIN
  declare @needUpdate table (ID int not null)
  insert into @needUpdate (ID) 
  select A.ID from MNT_PLAN A where A.NEXTDATE <= @now and A.S_S = 1 and A.CRMODE in (1,2)

  declare @newOperations table (OPERTYPE int,USERID int,MNT_PLANID int,MNTPLAN_S_CR int,MNT_HIGHPR datetime,TODOTEXT ntext,EQID int)

  /* mode 1 */   
  insert into @newOperations(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT)
  select A.OPERID,null,A.ID,A.S_CR,dbo.MNT_HIGHPRDATETIME(@now,A.HP_DAY,A.HP_HOUR,A.HP_MINUTE),A.TODO
    from MNT_PLAN A 
   where A.ID in (select G.ID from @needUpdate G)
     and A.CRMODE = 1
  
  /* mode 2 */
  insert into @newOperations(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT)
  select A.OPERID,D.ID,A.ID,A.S_CR,dbo.MNT_HIGHPRDATETIME(@now,A.HP_DAY,A.HP_HOUR,A.HP_MINUTE),A.TODO
    from MNT_PLAN A 
    left join PR_OPERATIONS B on B.ID = A.OPERID
    left join PR_EMPL_TO_OPERGR C on C.GROUPID = B.OPERGRID
    left join DEF_USERS D on D.EMPLOYEEID = C.EMPLOYEEID
    left join COM_EMPLOYEE E on E.ID = C.EMPLOYEEID
   where A.ID in (select G.ID from @needUpdate G)
     and A.CRMODE = 2
     and E.S_S = 1
     and isnull(C.DBEG,'19900101') <= @now and isnull(C.DEND,'40000101') >= @now
  

  insert into PR_OPERATION (GID,S_S,OPERTYPEID,S_CDT,S_CR,USERINPROGRESS,TODOTEXT,MNT_PLANID,HIGHPRDATE,URGENCY,EQID)
  select newid(),1000032,A.OPERTYPE,@now,A.MNTPLAN_S_CR,A.USERID,A.TODOTEXT,MNT_PLANID,MNT_HIGHPR,2,EQID
  from @newOperations A 
  
  update MNT_PLAN set LASTDATE = @now where ID in (select B.ID from @needUpdate B)
  update MNT_PLAN set NEXTDATE = dbo.MNT_NEXT_SNOOZE2(ID, null) where ID in (select B.ID from @needUpdate B)

END

update MNT_PLAN_EQ set NEXTDATE = dbo.MNT_NEXT_SNOOZE2(null,ID) 
where NEXTDATE is null 
  and VNESHID in (select B.ID from MNT_PLAN B where B.S_S = 1 and B.CRMODE in (3,4) and isnull(B.SHIFTFROMLASTCMPLDATE,0)<>1)
  and exists (select L.ID from MNT_PLAN L where L.ID = MNT_PLAN_EQ.VNESHID and isnull(L.SHIFTFROMLASTCMPLDATE,0) <> 1) /*fix KB1221*/

if exists(select A.ID 
            from MNT_PLAN_EQ A with (nolock) 
            left join MNT_PLAN B with (nolock) on B.ID = A.VNESHID
           where A.NEXTDATE <= @now 
             and B.S_S = 1 
             and B.CRMODE in (3,4)
           )
BEGIN
  declare @needUpdateEq table (ID int not null)
  insert into @needUpdateEq (ID) 
  select A.ID 
    from MNT_PLAN_EQ A with (nolock) 
    left join MNT_PLAN B with (nolock) on B.ID = A.VNESHID
   where A.NEXTDATE <= @now 
     and B.S_S = 1 
     and B.CRMODE in (3,4)

  declare @newOperationsEq table (OPERTYPE int,USERID int,MNT_PLANID int,MNTPLAN_S_CR int,MNT_HIGHPR datetime,TODOTEXT ntext,EQID int,MNT_PLAN_EQROW_ID int)
  
  /* mode 3 */
  insert into @newOperationsEq(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT,EQID,MNT_PLAN_EQROW_ID)
  select B.OPERID,null,B.ID,B.S_CR,dbo.MNT_HIGHPRDATETIME(@now,B.HP_DAY,B.HP_HOUR,B.HP_MINUTE),B.TODO,C.ID,A.ID
    from MNT_PLAN_EQ A 
    left join MNT_PLAN B on B.ID = A.VNESHID
    left join EQ_EQUIPMENT C on C.ID = A.EQID
   where A.ID in (select G.ID from @needUpdateEq G)
     and B.CRMODE = 3
     /*and C.S_S IN( 1000173, 1000174, 2130044)*/ /*in use, reserve, in calibration*/
     and dbo.MNT_EQ_EXEC_STATE_CHECK(C.S_S,B.EXEC_EQ_STATES) = 1  /*KB3303*/
     and dbo.MNT_EQ_CHECK_PREVIOUSCOMPLETED(B.CHECKPREVIOUSCOMPLETED,C.ID,B.ID) = 1 /*KB3488*/

  /* mode 4 */
  insert into @newOperationsEq(OPERTYPE,USERID,MNT_PLANID,MNTPLAN_S_CR,MNT_HIGHPR,TODOTEXT,EQID,MNT_PLAN_EQROW_ID)
  select B.OPERID,D.ID,B.ID,B.S_CR,dbo.MNT_HIGHPRDATETIME(@now,B.HP_DAY,B.HP_HOUR,B.HP_MINUTE),B.TODO,C.ID,A.ID
    from MNT_PLAN_EQ A 
    left join MNT_PLAN B on B.ID = A.VNESHID
    left join EQ_EQUIPMENT C on C.ID = A.EQID
    left join DEF_USERS D on D.EMPLOYEEID = C.RESP_EMPLID
   where A.ID in (select G.ID from @needUpdateEq G)
     and B.CRMODE = 4
     /*and C.S_S IN( 1000173, 1000174, 2130044)*/ /*in use, reserve, in calibration*/
     and dbo.MNT_EQ_EXEC_STATE_CHECK(C.S_S,B.EXEC_EQ_STATES) = 1  /*KB3303*/
     and dbo.MNT_EQ_CHECK_PREVIOUSCOMPLETED(B.CHECKPREVIOUSCOMPLETED,C.ID,B.ID) = 1 /*KB3488*/

  declare @newids table (OPERID int)

  insert into PR_OPERATION (GID,S_S,OPERTYPEID,S_CDT,S_CR,USERINPROGRESS,TODOTEXT,MNT_PLANID,HIGHPRDATE,URGENCY,EQID,MNT_PLAN_EQROW_ID)
  output inserted.ID into @newids
  select newid(),1000032,A.OPERTYPE,@now,A.MNTPLAN_S_CR,A.USERID,A.TODOTEXT,MNT_PLANID,MNT_HIGHPR,2,EQID,MNT_PLAN_EQROW_ID
  from @newOperationsEq A 
  
  /*
  MNT_PLAN_EQ.LEMODE
  0 - none
  1 - Put specified linked equipment into operation
  2 - Put all linked equipment from affected equipment into operation
  */
  
  insert into PR_OPERATION_EQUIPMENT (GID,S_CR,S_CDT,OPERID,EQID,WASAUTOCREATED)
  select newid(),B.S_CR,@now,B.ID,D.EQID,1
  from @newids A
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  left join MNT_PLAN_EQ C with (nolock) on C.ID = B.MNT_PLAN_EQROW_ID
  left join MNT_PLAN_EQ_LINKED_EQ D with (nolock) on D.VNESHID = C.ID
  where C.ID is not null
    and C.LEMODE = 1
    and D.EQID is not null
    
  insert into PR_OPERATION_EQUIPMENT (GID,S_CR,S_CDT,OPERID,EQID,WASAUTOCREATED)
  select newid(),B.S_CR,@now,B.ID,D.LINKED_EQID,1
  from @newids A
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  left join MNT_PLAN_EQ C with (nolock) on C.ID = B.MNT_PLAN_EQROW_ID
  left join EQ_EQUIPMENT_LINKED D with (nolock) on D.VNESHID = C.EQID
  where C.ID is not null
    and C.LEMODE = 2
    and D.LINKED_EQID is not null
    
    
  
  update MNT_PLAN_EQ set LASTDATE = @now 
  where ID in (select B.ID from @needUpdateEq B)  
    and ID in (select MNT_PLAN_EQROW_ID from @newOperationsEq)
  
  update MNT_PLAN_EQ set NEXTDATE = dbo.MNT_NEXT_SNOOZE2(null, ID) 
  where ID in (select B.ID from @needUpdateEq B)
    and ID in (select MNT_PLAN_EQROW_ID from @newOperationsEq)
  
  /*KB614*/
  update PE 
    set NEXTDATE = null
  from MNT_PLAN_EQ PE
  left join MNT_PLAN P on P.ID = PE.VNESHID
  where PE.ID in (select B.ID from @needUpdateEq B)   
    and isnull(P.SHIFTFROMLASTCMPLDATE,0) = 1
    and PE.ID in (select MNT_PLAN_EQROW_ID from @newOperationsEq)
  
  
  update MNT_PLAN set NEXTDATE = (select min(B.NEXTDATE) from MNT_PLAN_EQ B where B.VNESHID = MNT_PLAN.ID)
  where MNT_PLAN.ID in (select distinct F.VNESHID from MNT_PLAN_EQ F where F.ID in (select B.ID from @needUpdateEq B))
     
END

if exists (select A.ID from PR_OPERATION A where A.MNT_PLANID is not null and A.HIGHPRDATE <= @now and isnull(A.URGENCY,0) < 10)
BEGIN

  update PR_OPERATION set URGENCY = 10 where MNT_PLANID is not null and HIGHPRDATE <= @now and isnull(URGENCY,0) < 10

END


set nocount off