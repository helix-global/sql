create function [dbo].[EQ_EQUIPMENT_PARAM_DATETIME](@EqID int, @ParamID int)
returns datetime as 
begin

  declare @val sql_variant
  set @val = dbo.EQ_EQUIPMENT_PARAM(@EqID, @ParamID)
  if @val is null
    return null
    
  if SQL_VARIANT_PROPERTY(@val,'BaseType')  = 'datetime'
     return convert(datetime,@val)   
  
  return null

end