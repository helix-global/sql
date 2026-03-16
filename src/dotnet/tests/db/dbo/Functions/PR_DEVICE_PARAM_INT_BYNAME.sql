create function [dbo].[PR_DEVICE_PARAM_INT_BYNAME](@DeviceID int, @ParamName nvarchar(300))
returns int as 
begin

  declare @mtid int
  
  select @mtid = B.TYPEID
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.ID = @DeviceID

  declare @ParamID int
  select @ParamID = A.ID
  from PR_MODELTYPE_PARAMS A with (nolock)
  where A.TYPEID = @mtid
    and A.NAME = @ParamName


  return dbo.PR_DEVICE_PARAM_INT(@DeviceID, @ParamID)
  
end