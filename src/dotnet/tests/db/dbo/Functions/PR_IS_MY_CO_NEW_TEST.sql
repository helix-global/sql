create function [dbo].[PR_IS_MY_CO_NEW_TEST](@UserID int,@OnDate datetime)  
 returns @res table(ID INT)
as 
begin  
  declare @emplID int
  select @emplID = U.EMPLOYEEID from DEF_USERS U with (nolock) where U.ID = @UserID
  
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
  where A.COMPLETED_DT is null
    and A.S_S in (1000032) /*pending*/
    and D.S_S in (1000008,1000011,1000029) /*in production, in service, pending production*/
    and A.USERINPROGRESS is null
    and B.OPERGRID in (select F.GROUPID from PR_EMPL_TO_OPERGR F with (nolock) 
                        where F.EMPLOYEEID = @emplID and isnull(F.DBEG,'19900101') <= @OnDate and isnull(F.DEND,'40000101') >= @OnDate)
    and isnull(G.VISTYPE,0) <> 1
    and not exists (select H.ID from PR_OPERATION H with (nolock) 
                     where H.DEVICEID = A.DEVICEID and H.ORDERID = A.ORDERID and H.OPERGR > 0 and H.OPERGR = A.OPERGR and H.USERINPROGRESS <> @UserID)
    and not exists (select K.DEVICEID from PR_SHARED_OPERATION_APP K with (nolock) 
                     where K.DEVICEID = A.DEVICEID and K.MAPOPERID = A.REVOPERID) 
      
  
  
  return

end