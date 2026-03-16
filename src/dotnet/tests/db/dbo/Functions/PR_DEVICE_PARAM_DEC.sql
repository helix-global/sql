CREATE function [dbo].[PR_DEVICE_PARAM_DEC](@DeviceID int, @ParamID int)
returns decimal as 
begin
  declare @val sql_variant
  set @val = dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID)
  if @val is null
    return null
    
  declare @valstr varchar(200)
  set @valstr = CAST(@val as varchar(200))
  if len(ltrim(@valstr)) = 0
    return null
    
  return cast(@val as decimal)
end