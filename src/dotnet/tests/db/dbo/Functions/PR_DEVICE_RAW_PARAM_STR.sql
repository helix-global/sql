create function [dbo].[PR_DEVICE_RAW_PARAM_STR](@DeviceID int, @ParamID int)
returns nvarchar(max) as 
begin
  declare @val sql_variant
  set @val = dbo.PR_DEVICE_RAW_PARAM(@DeviceID, @ParamID)
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