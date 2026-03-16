CREATE function [dbo].[PR_DEVICE_PARAM_IN_LIST_INCACHE](@DeviceID int, @MtID int, @ParamN int)
returns int as 
begin
  
  declare @prmID int
  
  select top 1 @prmID = A.ID 
  from PR_MODELTYPE_PARAMS A with (nolock) 
  where A.TYPEID = @MtID
   and A.USEINLIST = @ParamN
  
  
  declare @prmEx int
    
  select @prmEx = A.PARAMID from PR_LIST_PARAMS_CACHE A with (nolock) where A.DEVICEID = @DeviceID and A.PARAMID = @prmID
  if (@prmEx is not null)    
    return 1
    
  
  return null   
  

end