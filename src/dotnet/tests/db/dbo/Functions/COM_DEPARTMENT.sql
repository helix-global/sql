create function [dbo].[COM_DEPARTMENT]()
returns int as 
begin
  /*выдает ID подразделения текущего пользователя */
  declare @res int
  select @res = B.DEPID
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
  where A.ID = dbo.DEF_USERID()
  
  return @res
  
end