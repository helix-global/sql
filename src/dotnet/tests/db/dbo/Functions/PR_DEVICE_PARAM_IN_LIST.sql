CREATE function [dbo].[PR_DEVICE_PARAM_IN_LIST](@DeviceID int, @ParamN int)
returns sql_variant as 
begin
  declare @prmID int
  select top 1 @prmID = A.ID 
  from PR_MODELTYPE_PARAMS A with (nolock) 
  where A.TYPEID = (select M.TYPEID 
                      from PR_MODELS M with (nolock)  
                     where M.ID = (select D.MODELID 
                                     from PR_DEVICE D with (nolock)
                                    where D.ID = @DeviceID))
     and A.USEINLIST = @ParamN
  
  
  if @prmID is not null
    return dbo.PR_DEVICE_PARAM(@DeviceID,@prmID)
  
  return null
end