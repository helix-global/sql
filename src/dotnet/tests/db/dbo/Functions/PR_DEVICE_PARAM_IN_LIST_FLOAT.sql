CREATE function [dbo].[PR_DEVICE_PARAM_IN_LIST_FLOAT](@DeviceID int, @ParamID int)
returns float as 
begin
  declare @val sql_variant
  declare @prmEx int
    
  select @val = A.PVALUE, @prmEx = A.PARAMID from PR_LIST_PARAMS_CACHE A with (nolock) where A.DEVICEID = @DeviceID and A.PARAMID = @ParamID
  if (@prmEx is null)    
    set @val = dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID)
    
  if @val is null
    return null
    
  declare @valstr varchar(200)
  set @valstr = CAST(@val as varchar(200))
  set @valstr = REPLACE(@valstr,',','.')
  
  if isnumeric(@valstr) = 1 and ltrim(rtrim(@valstr)) <> '-'
     return cast(@valstr as float);
  
  return null   
  
  --return cast(@val as float)
end