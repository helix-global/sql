CREATE function [dbo].[PR_DEVICE_PARAM_IN_LIST_STR](@DeviceID int, @ParamN int)
returns nvarchar(200) as 
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
    return cast (dbo.PR_DEVICE_PARAM(@DeviceID,@prmID) as nvarchar(200))

  return null
end