create function [dbo].[FC_REPORT_PARAM_DATE](@aRepID int, @aParamID int)
returns datetime as 
begin

  declare @val sql_variant
  set @val = dbo.FC_REPORT_PARAM(@aRepID,@aParamID)
  if @val is null
    return null
    
  return convert(date,@val,104)
end