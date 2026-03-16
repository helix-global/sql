CREATE function [dbo].[WEB_GET_CONTEXT](@aUserID int)
returns @res table (USERID int, FULLNAME nvarchar(300), DEPID int, DEPCODE nvarchar(50), DEPNAME nvarchar(250), EMPLID int )
as 
begin
  /* DEVOPS:6239 - add EMPLOYEEE ID to result */
  insert into @res (USERID, FULLNAME , DEPID, DEPCODE, DEPNAME, EMPLID)
  select A.ID, A.FULLNAME, B.DEPID, C.CODE, C.NAME, A.EMPLOYEEID
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
  left join COM_DEPARTMENTS C with (nolock) on C.ID = B.DEPID
  where A.ID = @aUserID

  return

end