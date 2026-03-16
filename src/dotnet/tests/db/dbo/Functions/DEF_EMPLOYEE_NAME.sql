create function [dbo].[DEF_EMPLOYEE_NAME](@UserID int)
returns nvarchar(200) as 
begin
  declare @res nvarchar(200)
  
  select @res = B.NAME 
    from DEF_USERS A with (nolock) 
   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
   where A.ID = @UserID
   
  return @res
end