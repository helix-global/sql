create function [dbo].[PR_DEVICE_ACCOUNTING](@DeviceID int)
returns int as 
begin

  declare @res int
  
  select top 1 @res = isnull(C.ACCMODE,0)
  from PR_DEVICE A with (nolock) 
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_MODELTYPE C with (nolock) on C.ID = B.TYPEID
  where A.ID = @DeviceID
  
  return @res  

end