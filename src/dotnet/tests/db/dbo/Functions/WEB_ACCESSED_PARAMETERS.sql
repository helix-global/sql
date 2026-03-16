create function [dbo].[WEB_ACCESSED_PARAMETERS](@aUserID int, @aDeviceID int)
returns @res table(PARAMID INT) as
begin
  
  insert into @res (PARAMID)
  select P.ID
  from PR_MODELTYPE_PARAMS P with (nolock) 
  left join PR_MODELS M with (nolock) on P.TYPEID = M.TYPEID
  left join PR_DEVICE D with (nolock) on M.ID = D.MODELID
  where D.ID=@aDeviceID
    and (M.ID in (select ID from dbo.PR_ACCESS_MODELS(@aUserID,4,getdate())) or dbo.PR_ACCESS_PARAMETER(@aUserID, @aDeviceID, P.ID) = 1)

  return
  
end