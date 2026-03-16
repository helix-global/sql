CREATE function [dbo].[PR_DEVICE_PARAM_DATETIME](@DeviceID int, @ParamID int)
returns datetime as 
begin
  declare @val sql_variant
  
  set @val = dbo.PR_DEVICE_PARAM(@DeviceID, @ParamID)
  if @val is null
    return null

  if SQL_VARIANT_PROPERTY(@val,'BaseType')  = 'datetime'
     return convert(datetime,@val)
     
  return null   
end