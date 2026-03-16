CREATE function [dbo].[PR_MODEL_DEPID] (@ModelID int)
returns int
as 
begin

   declare @depID int
   select @depID = B.DEPID
   from PR_MODELS B with (nolock)
   where B.ID = @ModelID

   return @depID

end