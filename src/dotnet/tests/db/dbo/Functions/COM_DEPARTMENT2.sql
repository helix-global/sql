create function [dbo].COM_DEPARTMENT2(@aUserID int)
returns int as 
begin
  /*выдает ID подразделения  пользователя */
  declare @res int
  select @res = B.DEPID
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
  where A.ID = @aUserID
  
  return @res
  
end