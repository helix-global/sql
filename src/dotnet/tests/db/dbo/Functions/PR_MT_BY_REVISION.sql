create function [dbo].[PR_MT_BY_REVISION] (@RevisionID int)
returns int
as 
begin

   declare @MTID int
   select @MTID = C.TYPEID
   from PR_REVISION B with (nolock)
   left join PR_MODELS C with (nolock) on C.ID = B.MODELID
   where B.ID = @RevisionID

   return @MTID

end