create function [dbo].PR_DEP_HAS_MODELS(@aDepID int)
returns int
as
begin

if exists (select A.ID from PR_MODELS A with (nolock) where A.DEPID = @aDepID)
  return 1

if exists (select A.ID from PR_MODELS A with (nolock) where A.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS(@aDepID)))
  return 1
     
return 0  

end;