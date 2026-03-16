create function [dbo].[WEB_ACCESS_PARAMETER](@aUserID int, @aDeviceID int, @aParamID int)
returns int as 
begin
  
  if (dbo.PR_ACCESS_PARAMETER(@aUserID, @aDeviceID, @aParamID) = 1)
    return 1
    
  if exists (
    select B.ID 
    from PR_DEVICE A with (nolock) 
    left join PR_MODELS B with (nolock) on B.ID = A.MODELID
    where A.ID = @aDeviceID
      and B.ID in (select ID from dbo.PR_ACCESS_MODELS(@aUserID,4,getdate()))
    )
    return 1 
    
  return 0
  
end