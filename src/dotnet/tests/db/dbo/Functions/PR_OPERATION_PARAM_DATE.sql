create function [dbo].[PR_OPERATION_PARAM_DATE](@OperID int, @ParamID int)
returns datetime as 
begin
  declare @val sql_variant
  
  set @val = dbo.PR_OPERATION_PARAM(@OperID, @ParamID)
  if @val is null
    return null

  if SQL_VARIANT_PROPERTY(@val,'BaseType')  = 'datetime'
     return convert(date,@val)   /*return convert(date,@val,104)*/
     
  return null   
end