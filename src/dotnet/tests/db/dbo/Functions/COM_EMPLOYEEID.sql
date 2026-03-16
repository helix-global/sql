create function [dbo].[COM_EMPLOYEEID]()
returns int as 
begin
  declare @res int
  select @res = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = dbo.DEF_USERID()
  return @res
end