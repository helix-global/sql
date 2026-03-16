CREATE function [dbo].[PR_DEVICE_PARAM_BYNAME](@DeviceID int, @ParamName nvarchar(300), @OnlyShared int)
returns sql_variant as 
begin

  declare @mtid int
  
  select @mtid = B.TYPEID
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.ID = @DeviceID

  declare @ParamID int
  declare @Shared int
  select @ParamID = A.ID
        ,@Shared = isnull(A.SHAREPRM,0)
  from PR_MODELTYPE_PARAMS A with (nolock)
  where A.TYPEID = @mtid
    and A.NAME = @ParamName
    
  if @OnlyShared = 1 and @Shared <> 1
    return null  

  declare @val sql_variant
  set @val = dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID)

  return @val

end