
create function [dbo].[PR_OPER_ACCESS5_TAB](@aUserID int,@aDate datetime,@aReturnMode int,@dBeg datetime, @dEnd datetime)
returns table 
as 
    return
    

/*
  @aReturnMode - 1 - только pending
*/
/*
  declare @deps table (ID int not null)
  insert into @deps (ID)
  select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@aDate)
*/
  with  deps as (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@aDate) )
       ,empl as (select U.EMPLOYEEID as ID from DEF_USERS U with (nolock) where U.ID = @aUserID)

  select A.ID from PR_OPERATION A with (nolock) 
  where A.USERINPROGRESS = @aUserID
    and A.S_S = 1000032

  union
  select A.ID from PR_OPERATION A with (nolock) 
  left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
  where A.ORDERID is not null
    and B.DEPARTMENTID in (select ID from deps) 
    and A.S_S = 1000032

  union
  select A.ID from PR_OPERATION A with (nolock) 
  left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID
  left join PR_OPERATIONS_GR T1000341 with (nolock) on T1000341.ID = T1000242.OPERGRID
  where A.ORDERID is null
     and T1000341.DEPARTMENTID in (select ID from deps) 
     and A.S_S = 1000032

  
  union
  select A.ID from PR_OPERATION A with (nolock) 
  left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
  left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID  
  left join PR_EMPL_TO_OPERGR H with (nolock) on H.GROUPID = T1000242.OPERGRID and H.EMPLOYEEID in (select ID from empl) and H.DEPID = B.DEPARTMENTID
  where H.ID is not null
    and isnull(H.DBEG,'19100101') < @aDate
	and isnull(H.DEND,'40000101') > @aDate
	and B.DEPARTMENTID not in (select ID from deps) 
	and A.S_S = 1000032