create function [dbo].[PR_EMPL_DELAYS](@aUserID int,@aEmplID int,@aDay datetime)
returns int as 
begin

   declare @emplID int
   if @aEmplID is not null
     set @emplID = @aEmplID
   else
     select @emplID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID

   declare @dd datetime
   set @dd = CAST(@aDay as date)

   return null

end