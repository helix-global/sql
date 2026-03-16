create function [dbo].[PU_MODEL_BATCH_TRACKED](@aModelID int)
returns int as 
begin
   declare @res int
   select top 1 @res = A.BATCH_MODE from PU_BATCH_TR_MODELS A with (nolock) where A.MODELID = @aModelID
   return isnull(@res,0)
end