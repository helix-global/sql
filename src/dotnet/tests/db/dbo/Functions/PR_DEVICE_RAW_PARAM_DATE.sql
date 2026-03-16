create function [dbo].[PR_DEVICE_RAW_PARAM_DATE](@DeviceID int, @ParamID int)
returns datetime as 
begin
  declare @val sql_variant
  
  set @val = dbo.PR_DEVICE_RAW_PARAM(@DeviceID, @ParamID)
  if @val is null
    return null

  if SQL_VARIANT_PROPERTY(@val,'BaseType')  = 'datetime'
     return convert(date,@val)   /*return convert(date,@val,104)*/
     
  return null   
end