create function [dbo].[PR_MODELS_DEP_ACCESS_TAB](@aUser int,@aMode int,@aDate datetime)
returns @res table (ID int) as 
begin
  
  insert into @res (ID)
  select B.ID from PR_MODELS B with (nolock) where B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUser,@aMode,@aDate))
  return 
  
end