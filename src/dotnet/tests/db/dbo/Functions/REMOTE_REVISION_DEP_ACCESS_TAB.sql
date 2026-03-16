create function [dbo].[REMOTE_REVISION_DEP_ACCESS_TAB](@aUser int,@aMode int,@aDate datetime)
returns @res table (ID int) as 
begin
  
  declare @deps table (ID int)
  
  insert into @deps (ID)
  select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUser,@aMode,@aDate)
  
  insert into @res 
  select A.ID
  from PR_REVISION A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_MODELTYPE C with (nolock) on C.ID = B.TYPEID
  where C.DEPARTMENTID in (select ID from @deps )
    and B.DEPID <> C.DEPARTMENTID
  
  
  return 
end