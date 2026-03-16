CREATE function [dbo].[PR_DEVICE_PARAM_FLOAT](@DeviceID int, @ParamID int)
returns float as 
begin
  declare @val sql_variant
  set @val = dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID)
  if @val is null
    return null
    
  declare @valstr varchar(200)
  set @valstr = CAST(@val as varchar(200))
  set @valstr = REPLACE(@valstr,',','.')
  
  if isnumeric(@valstr) = 1
     return cast(@valstr as float);
  
  return null
  
end