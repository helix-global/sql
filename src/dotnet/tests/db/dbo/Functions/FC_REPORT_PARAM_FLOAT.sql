create function [dbo].[FC_REPORT_PARAM_FLOAT](@aRepID int,@aParamID int)
returns float as 
begin
  declare @val sql_variant
  set @val = dbo.FC_REPORT_PARAM(@aRepID,@aParamID)
  if @val is null
    return null
    
  declare @valstr varchar(200)
  set @valstr = CAST(@val as varchar(200))
  set @valstr = REPLACE(@valstr,',','.')
  
  return cast(@valstr as float);
  
end