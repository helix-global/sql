
CREATE function [dbo].[PR_IS_MY_CO_NEW_TEST4](@UserID int,@OnDate datetime)  
 returns @res table(ID INT)
as 
begin  
  declare @emplID int
  declare @depID int
  select @emplID = U.EMPLOYEEID 
        ,@depID = B.DEPID
  from DEF_USERS U with (nolock) 
  left join COM_EMPLOYEE B with (nolock) on B.ID = U.EMPLOYEEID
  where U.ID = @UserID
  
  insert into @res (ID)
  select A.ID 
  from PR_OPERATION_INPROGRESS A with (nolock, noexpand)
  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
  where A.S_S in (1000031,1000033,1000032) /*in progress,postponed,pending*/
    and (D.S_S in (1000008,1000011,1000029) /*in production, in service, pending production*/ or A.DEVICEID is null /*preparatory*/ )
    and A.USERINPROGRESS = @UserID
    
  declare @PlanID int -- последний утверждённый документ планирования, в который попадает дата @OnDate.
  
  select top 1 @PlanID = RP.ID 
	from PR_RESOURCE_PLAN RP with (nolock)
   where @OnDate >= RP.FROMDT 
	 and @OnDate < RP.TODT
	 and RP.APPLYDT is not null
	 and RP.DEPID = @depID
	order by RP.APPLYDT desc

   declare @Groups table (ID int, ORDTYPE int,DEPID int unique (DEPID,ID) )
   
   insert into @Groups (ID,ORDTYPE,DEPID)  
   select F.GROUPID,F.ORDTYPE,F.DEPID 
   from PR_EMPL_TO_OPERGR F with (nolock) 
   where F.EMPLOYEEID = @emplID 
     and isnull(F.DBEG,'19900101') <= @OnDate 
     and isnull(F.DEND,'40000101') >= @OnDate
   
   if @PlanID is not null
   begin
	
	insert into @Groups (ID,ORDTYPE, DEPID)  
    select distinct v.OPERGRID,0,@depID /*14.07.2016 добавлена запись DEPID, иначе этот функционал не работал из-за строки 1*/
	from PR_RESOURCE_PLAN_T v 
	where v.VNESHID = @PlanID 
	  and v.EMPID = @emplID	
	  and v.FROMDT <= @OnDate 
	  and DATEADD(DAY, 1, v.TODT) > @OnDate 
	  and v.[ACTION] = 1

	/*удаляем группы которые запрещены в документе pr_resource_plan*/
	delete from @Groups 
	where ID in (
    select distinct v.OPERGRID 
	from PR_RESOURCE_PLAN_T v 
	where v.VNESHID = @PlanID 
	  and v.EMPID = @emplID	
	  and v.FROMDT <= @OnDate 
	  and DATEADD(DAY, 1, v.TODT) > @OnDate 
	  and v.[ACTION] = 2
	  )
	
  end	
    
  insert into @res (ID)
  select A.ID 
  from PR_OPERATION_NOCMPL A with (nolock, noexpand)
  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
  left join PR_OPERATIONS_GR G with (nolock) on G.ID = B.OPERGRID
  left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
  where A.OPERTYPEID in (select K.OPERTYPEID from PR_OPERATIONS_RAW_BYUSER K with (nolock, noexpand) where K.USERID = @UserID)
    and D.S_S in (1000008,1000011,1000029,1000078) /*in production, in service, pending production, failed*/
    and B.OPERGRID in (select F.ID from @Groups F  
                        where F.DEPID = O.DEPARTMENTID /*1*/
                          and (F.ORDTYPE = 0 
                               or (F.ORDTYPE = 1 and O.ORDERTYPE = 0) /*prod. order*/
                               or (F.ORDTYPE = 2 and O.ORDERTYPE = 1) /*serv. order*/
                              )
                       )
    and isnull(G.VISTYPE,0) <> 1
    and not exists (select H.ID from PR_OPERATION_INPROGRESS H with (nolock, noexpand) 
                     where H.DEVICEID = A.DEVICEID and H.ORDERID = A.ORDERID and H.OPERGR > 0 and H.OPERGR = A.OPERGR and H.USERINPROGRESS <> @UserID)
    and not exists (select K.DEVICEID from PR_SHARED_OPERATION_APP K with (nolock) 
                     where K.DEVICEID = A.DEVICEID and K.MAPOPERID = A.REVOPERID) 
    and (D.S_S <> 1000078 /*failed*/ or B.OPERTYPE = 12 /*failed params*/)
    and not exists (select R.ID from PR_OPERATION_BLOCKOTHERS R with (nolock, noexpand) 
                     where R.DEVICEID = A.DEVICEID and R.ORDERID = A.ORDERID and R.ID <> A.ID )
    
      
  /*01.09.2015 added from maintenance plans */      
  insert into @res (ID)
  select A.ID 
  from PR_OPERATION A with (nolock)
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
  left join PR_OPERATIONS_GR G with (nolock) on G.ID = B.OPERGRID
  where A.MNT_PLANID is not null /* Maintenance plan */
    and A.COMPLETED_DT is null
    and A.S_S in (1000032) /*pending*/
    and A.DEVICEID is null
    and ( A.USERINPROGRESS = @UserID or (A.USERINPROGRESS is null and B.OPERGRID in (select F.ID from @Groups F where F.DEPID = G.DEPARTMENTID )))
    and isnull(G.VISTYPE,0) <> 1
	
      
   return

end