CREATE function [dbo].[PR_IS_MY_CO_NEW2_TEST](@UserID int,@OnDate datetime)  
returns table 
as 
    return
    with props as ( select U.EMPLOYEEID, B.DEPID  from DEF_USERS U with (nolock) left join COM_EMPLOYEE B with (nolock) on B.ID = U.EMPLOYEEID where U.ID = @UserID )
       /*, plant as ( select top 1 RP.ID 
	                  from PR_RESOURCE_PLAN RP with (nolock)
                     where @OnDate >= RP.FROMDT 
	                   and @OnDate < RP.TODT
	                   and RP.APPLYDT is not null
	                   and RP.DEPID in (select DEPID from props)
	                 order by RP.APPLYDT desc 
	                 )
	                 */
        , groups as ( select F.GROUPID,F.ORDTYPE,F.DEPID 
                        from PR_EMPL_TO_OPERGR F with (nolock) 
                       where F.EMPLOYEEID in (select EMPLOYEEID from props) 
                         and isnull(F.DBEG,'19900101') <= @OnDate 
                         and isnull(F.DEND,'40000101') >= @OnDate
                         )
  select A.ID 
  from PR_OPERATION_NOCMPL AA with (nolock)
  left join PR_OPERATION A with (nolock) on A.ID = AA.ID
  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
  left join PR_OPERATIONS_GR G with (nolock) on G.ID = B.OPERGRID
  left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
  where D.S_S in (1000008,1000011,1000029,1000078) /*in production, in service, pending production, failed*/
    and B.OPERGRID in (select F.GROUPID from groups F  
                        where F.DEPID = O.DEPARTMENTID /*1*/
                          and (F.ORDTYPE = 0 
                               or (F.ORDTYPE = 1 and O.ORDERTYPE = 0) /*prod. order*/
                               or (F.ORDTYPE = 2 and O.ORDERTYPE = 1) /*serv. order*/
                              )
                       )
    and isnull(G.VISTYPE,0) <> 1
    and not exists (select H.ID from PR_OPERATION_INPROGRESS H with (nolock) 
                     where H.DEVICEID = A.DEVICEID and H.ORDERID = A.ORDERID and H.OPERGR > 0 and H.OPERGR = A.OPERGR and H.USERINPROGRESS <> @UserID)
    and not exists (select K.DEVICEID from PR_SHARED_OPERATION_APP K with (nolock) 
                     where K.DEVICEID = A.DEVICEID and K.MAPOPERID = A.REVOPERID) 
    and (D.S_S <> 1000078 /*failed*/ or B.OPERTYPE = 12 /*failed params*/)
    and not exists (select R.ID from PR_OPERATION R with (nolock) 
                     where R.DEVICEID = A.DEVICEID and R.ORDERID = A.ORDERID and R.COMPLETED_DT is null and R.ID <> A.ID and isnull(R.HIDDENOTHER,0) = 1)
    
      
  /*01.09.2015 added from maintenance plans */      
  union
  select A.ID 
  from PR_OPERATION A with (nolock)
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
  left join PR_OPERATIONS_GR G with (nolock) on G.ID = B.OPERGRID
  where A.MNT_PLANID is not null /* Maintenance plan */
    and A.COMPLETED_DT is null
    and A.S_S in (1000032) /*pending*/
    and A.DEVICEID is null
    and ( A.USERINPROGRESS = @UserID or (A.USERINPROGRESS is null and B.OPERGRID in (select F.GROUPID from groups F where F.DEPID = G.DEPARTMENTID )))
    and isnull(G.VISTYPE,0) <> 1