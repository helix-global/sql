CREATE function [dbo].[FC_CODES_4_MODEL] (@aModelID int)
returns table 
as return
   select C.ID
   from PR_MODELS B with (nolock)
   left join FC_FAILURECODES C with (nolock) on /*C.DEPARTID = B.DEPID and*/ C.MTID = B.TYPEID
   where B.ID = @aModelID
     and C.S_S = 1