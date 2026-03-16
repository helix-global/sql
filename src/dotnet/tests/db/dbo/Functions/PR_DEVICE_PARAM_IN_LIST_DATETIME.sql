create function [dbo].[PR_DEVICE_PARAM_IN_LIST_DATETIME](@DeviceID int, @ParamID int)
returns datetime as 
begin
  declare @val sql_variant
  declare @prmEx int
    
  select @val = A.PVALUE, @prmEx = A.PARAMID from PR_LIST_PARAMS_CACHE A with (nolock) where A.DEVICEID = @DeviceID and A.PARAMID = @ParamID
  if (@prmEx is null)    
    set @val = dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID)
    
  if @val is null
    return null

  if SQL_VARIANT_PROPERTY(@val,'BaseType')  = 'datetime'
    return convert(datetime,@val)
     
  return null   
   
   
end