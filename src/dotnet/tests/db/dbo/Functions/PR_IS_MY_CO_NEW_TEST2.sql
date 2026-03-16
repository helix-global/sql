
CREATE function [dbo].[PR_IS_MY_CO_NEW_TEST2](@UserID int,@OnDate datetime)  
 returns @res table(ID INT)
as 
begin  
  declare @emplID int
  declare @depID int
  select @emplID = U.EMPLOYEEID from DEF_USERS U with (nolock) where U.ID = @UserID
  select @depID = dbo.COM_USER_DEPARTMENT(@UserID)

  
  insert into @res (ID)
  select A.ID 
  from PR_OPERATION A with (nolock)
  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
  where A.COMPLETED_DT is null
    and A.S_S in (1000031,1000033,1000032) /*in progress,postponed,pending*/
    and (D.S_S in (1000008,1000011,1000029) /*in production, in service, pending production*/ or A.DEVICEID is null /*preparatory*/ )
    and A.USERINPROGRESS = @UserID
    
    
  insert into @res (ID)
  select A.ID 
  from PR_OPERATION A with (nolock)
  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
  left join PR_OPERATIONS_GR G with (nolock) on G.ID = B.OPERGRID
  left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
  where A.COMPLETED_DT is null
    and A.S_S in (1000032) /*pending*/
    and D.S_S in (1000008,1000011,1000029) /*in production, in service, pending production*/
    and A.USERINPROGRESS is null
    and (B.OPERGRID in (select F.GROUPID from PR_EMPL_TO_OPERGR F with (nolock)
                        where F.EMPLOYEEID = @emplID and F.DEPID = O.DEPARTMENTID and isnull(F.DBEG,'19900101') <= @OnDate and isnull(F.DEND,'40000101') >= @OnDate)
		or
		/*берём не только назначенные группы операций, но и группы операций, разрешённые в документе pr_resource_plan*/
		B.OPERGRID in (select OPERGRID from PR_RESOURCE_PLAN_T V 
							join (	select top 1 -- последний утверждённый документ, в который попадает дата @OnDate.
										RP.ID
									from PR_RESOURCE_PLAN RP
									where
										@OnDate >= RP.FROMDT
									and
										@OnDate < RP.TODT
									and
										RP.APPLYDT is not null
									and
										RP.DEPID = @depID
									order by RP.APPLYDT desc) RP on V.VNESHID = RP.ID
							where V.EMPID = @emplID and @OnDate >= V.FROMDT and @OnDate < DATEADD(DAY,1,V.TODT) and V.[ACTION] = 1)
		)
    and isnull(G.VISTYPE,0) <> 1
    and not exists (select H.ID from PR_OPERATION H with (nolock) 
                     where H.DEVICEID = A.DEVICEID and H.ORDERID = A.ORDERID and H.OPERGR > 0 and H.OPERGR = A.OPERGR and H.USERINPROGRESS <> @UserID)
    and not exists (select K.DEVICEID from PR_SHARED_OPERATION_APP K with (nolock) 
                     where K.DEVICEID = A.DEVICEID and K.MAPOPERID = A.REVOPERID) 
      
  /*01.09.2015 added from maintenance plans */      
  insert into @res (ID)
  select A.ID 
  from PR_OPERATION A with (nolock)
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
  left join PR_OPERATIONS_GR G with (nolock) on G.ID = B.OPERGRID
  where A.MNT_PLANID is not null
    and A.COMPLETED_DT is null
    and A.S_S in (1000032) /*pending*/
    and A.DEVICEID is null
    and (    A.USERINPROGRESS = @UserID
         or (A.USERINPROGRESS is null and B.OPERGRID in (select F.GROUPID from PR_EMPL_TO_OPERGR F with (nolock) 
                                                          where F.EMPLOYEEID = @emplID 
                                                            and F.DEPID = G.DEPARTMENTID 
                                                            and isnull(F.DBEG,'19900101') <= @OnDate 
                                                            and isnull(F.DEND,'40000101') >= @OnDate))
		)												  
    and isnull(G.VISTYPE,0) <> 1
	
	/*удаляем те операции, группы которых запрещены в документе pr_resource_plan*/
	delete from @res
	where
		ID in (select op.ID from PR_OPERATION op
				join PR_OPERATIONS opt on op.OPERTYPEID = opt.ID
					join PR_RESOURCE_PLAN_T v on opt.OPERGRID = v.OPERGRID
						join (	select top 1 -- последний утверждённый документ, в который попадает дата @OnDate.
										RP.ID
									from PR_RESOURCE_PLAN RP
									where
										@OnDate >= RP.FROMDT
									and
										@OnDate < RP.TODT
									and
										RP.APPLYDT is not null
									and
										RP.DEPID = @depID
									order by RP.APPLYDT desc) RP on v.VNESHID = RP.ID
				where
					v.EMPID = @emplID
				and
					v.FROMDT <= @OnDate 
				and
					DATEADD(DAY, 1, v.TODT) > @OnDate
				and
					v.ACTION =2
						)
  
  return

end