create function [dbo].[COM_USER_TURN](@aEmplID int, @aDT datetime)
returns int as 
begin
  
   declare @baseDate date = cast(@aDT as date)  
   declare @wturn int
   select @wturn = A.WTURN from COM_TURNS A with (nolock) where A.EMPLID = @aEmplID and A.DD = @baseDate
   
   return ISNULL(@wturn,1)
  
end