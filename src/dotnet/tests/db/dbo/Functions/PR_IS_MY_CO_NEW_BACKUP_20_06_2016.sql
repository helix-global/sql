create function [dbo].[PR_IS_MY_CO_NEW_BACKUP_20_06_2016](@UserID int,@OnDate datetime)  
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
    and D.S_S in (1000008,1000011,1000029,1000078) /*in production, in service, pending production, failed*/
    and A.USERINPROGRESS is null
    and B.OPERGRID in (select F.GROUPID from PR_EMPL_TO_OPERGR F with (nolock) 
                        where F.EMPLOYEEID = @emplID 
                          and F.DEPID = O.DEPARTMENTID 
                          and isnull(F.DBEG,'19900101') <= @OnDate 
                          and isnull(F.DEND,'40000101') >= @OnDate
                          and (F.ORDTYPE = 0 
                               or (F.ORDTYPE = 1 and O.ORDERTYPE = 0) /*prod. order*/
                               or (F.ORDTYPE = 2 and O.ORDERTYPE = 1) /*serv. order*/
                              )
                       )
    and isnull(G.VISTYPE,0) <> 1
    and not exists (select H.ID from PR_OPERATION H with (nolock) 
                     where H.DEVICEID = A.DEVICEID and H.ORDERID = A.ORDERID and H.OPERGR > 0 and H.OPERGR = A.OPERGR and H.USERINPROGRESS <> @UserID)
    and not exists (select K.DEVICEID from PR_SHARED_OPERATION_APP K with (nolock) 
                     where K.DEVICEID = A.DEVICEID and K.MAPOPERID = A.REVOPERID) 
    and (D.S_S <> 1000078 /*failed*/ or B.OPERTYPE = 12 /*failed params*/)
      
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
	
  
  return

end