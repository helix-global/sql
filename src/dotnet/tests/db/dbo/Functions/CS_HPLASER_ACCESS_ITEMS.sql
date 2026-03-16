CREATE function [dbo].[CS_HPLASER_ACCESS_ITEMS](@aUserID int)
returns @res table (DEVICEID int )
as 
begin

  declare @depID int
  
  select @depID = B.DEPID 
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
  where A.ID = @aUserID
  
  
  insert into @res (DEVICEID) 
  select distinct A.DEVICEID 
  from CS_HPLASER_SUB_PERM_ITEMS A with (nolock)
  left join CS_HPLASER_SUB_PERM B with (nolock) on B.ID = A.VNESHID
  where B.DEPID = @depID
   and B.S_S = 2000001 /*approved*/
 
  return 
 
end