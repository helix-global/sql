create function [dbo].[COM_VACATION_ACCESS2](@aCR int, @aState int,@aEmplID int,@aUserID int,@aMode int,@aDate datetime)
returns int as 
begin

  declare @myEmplID int
  select @myEmplID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID
  
  if (@aState = 1)
  begin
    if (@aCR = @aUserID)
      return 1
    if (@myEmplID <> @aEmplID)
      return 0
  end  
    
  return dbo.COM_EMPLOYEE_ACCESS3(@aEmplID,@aUserID,@aMode,@aDate)
  
end