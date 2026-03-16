CREATE function [dbo].[PR_DEVICE_INVALUE_FLOAT](@DeviceID int, @ParamID int)
returns float as 
begin
  declare @val sql_variant
  select TOP (1) @val = PVALUE 
  FROM PR_DEVICE_IN_VALUES WITH (nolock)
  WHERE (DEVICEID = @DeviceID) AND (PARAMID = @ParamID)
  order by ID desc

  if @val is null
    return null
    
  declare @valstr varchar(200)
  set @valstr = CAST(@val as varchar(200))
  set @valstr = REPLACE(@valstr,',','.')
  
  return cast(@valstr as float);
  
end