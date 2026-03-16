create function [dbo].[COM_VACATION_ACCESS](@aState int,@aEmplID int,@aUserID int,@aMode int,@aDate datetime)
returns int as 
begin

  declare @myEmplID int
  select @myEmplID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID
  
  if (@myEmplID <> @aEmplID) and (@aState = 1)
    return 0
    
  return dbo.COM_EMPLOYEE_ACCESS3(@aEmplID,@aUserID,@aMode,@aDate)
  
end