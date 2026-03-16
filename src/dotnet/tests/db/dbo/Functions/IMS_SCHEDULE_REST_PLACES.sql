CREATE function [dbo].[IMS_SCHEDULE_REST_PLACES](@aDateID int, @aMaxPersons int, @aMode int)
returns int as 
begin

   if @aMaxPersons is null
     return null

   declare @occupated int
   select @occupated = count(*) from IMS_DEP_SCHEDULE_T A with (nolock) where isnull(A.SCHEDULEDATEID,0) = @aDateID
   
   set @occupated = isnull(@occupated,0)
   
   declare @res int = @aMaxPersons - @occupated
   
   if @res > 0
      return @res
   
   return 0 

end