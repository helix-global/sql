CREATE function [dbo].[PR_OPER_ACCESS4_TAB](@aUserID int,@dBeg datetime, @dEnd datetime)
returns @res table (ID int)
begin
/* отличается от PR_OPER_ACCESS3_TAB отбором по COMPLETED_DT*/
  declare @now datetime
  set @now = getdate()
  
  declare @ogroup table (DEPID int,OPERGRID int unique(DEPID,OPERGRID))
  insert into @ogroup (DEPID,OPERGRID)
  select distinct AA.DEPID,AA.GROUPID
    from PR_EMPL_TO_OPERGR AA with (nolock) 
   where /*AA.EMPLOYEEID = (select U.EMPLOYEEID from DEF_USERS U with (nolock) where U.ID = @aUserID)*/
         AA.ID in (select K.LINKID from PR_OPERATIONS_RAW_BYUSER K with (nolock, noexpand) where K.USERID = @aUserID) 
     and isnull(AA.DBEG,'19100101') < @now
     and isnull(AA.DEND,'40000101') > @now  
     
  declare @deps table (ID int primary key)
  insert into @deps (ID)
  select distinct AD.ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@now) AD

  insert into @res (ID)
  select A.ID
  from PR_OPERATION A with (nolock)
  left join PR_PRORDER T1000240 with (nolock) on T1000240.ID = A.ORDERID
  left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID
  left join PR_OPERATIONS_GR T1000341 with (nolock) on T1000341.ID = T1000242.OPERGRID
 where A.COMPLETED_DT >= @dBeg 
   and A.COMPLETED_DT < @dEnd
   and (exists (select FF.ID from @deps FF where FF.ID = isnull(T1000240.DEPARTMENTID,T1000341.DEPARTMENTID))
        or A.USERINPROGRESS = @aUserID
        or exists (select AA.OPERGRID from @ogroup AA where AA.DEPID = T1000240.DEPARTMENTID and AA.OPERGRID = T1000242.OPERGRID)
         )
  return 
end