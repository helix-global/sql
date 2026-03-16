create view FC_MANAGERS as
select A.ID,A.FULLNAME,B.ROLEINDEP,B.DEPID,A.EMPLOYEEID
from DEF_USERS A with (nolock)
left join COM_EMPLOYEE B  with (nolock) on B.ID = A.EMPLOYEEID
where A.S_S = 1
  and B.S_S = 1
  and A.ID in (select ID from dbo.DEF_USERSINGROUP(832))