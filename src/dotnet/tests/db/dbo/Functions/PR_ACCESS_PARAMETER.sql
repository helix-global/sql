create function [dbo].[PR_ACCESS_PARAMETER](@aUserID int, @aDeviceID int, @aParamID int)
returns int as 
begin

  declare @Sharing int
  select @Sharing = isnull(A.SHAREPRM,0) 
   from PR_MODELTYPE_PARAMS A with (nolock) 
  where A.ID = @aParamID
  
  if (@Sharing = 1)
    return 1
  
  declare @now datetime = getdate()
  
  if exists (
    select B.ID 
    from PR_DEVICE A with (nolock) 
    left join PR_MODELS B with (nolock) on B.ID = A.MODELID
    where A.ID = @aDeviceID
      and dbo.COM_DEP_ACCESS2(B.DEPID,1,@aUserID,@now) = 1
    )
    return 1
    
    
    
 return 0
  
end