create function [dbo].[PR_DEVICE_PARAM_IN_LIST_STR5](@DeviceID int, @ParamID int)
returns nvarchar(max) as 
begin
  declare @val sql_variant
  declare @prmEx int
    
  select @val = A.PVALUE, @prmEx = A.PARAMID from PR_LIST_PARAMS_CACHE A with (nolock) where A.DEVICEID = @DeviceID and A.PARAMID = @ParamID
  if (@prmEx is null)    
    set @val = dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID)
  
  if @val is null
    return null
    
  declare @dataType int
  select @dataType = A.DATATYPE from PR_MODELTYPE_PARAMS A with (nolock) where A.ID = @ParamID
  if @dataType = 9
    return convert(nvarchar,@val,104)
  else if @dataType = 2
    return convert(nvarchar,@val,104)+' '+convert(nvarchar,@val,108)

  return cast(@val as nvarchar(max))
end