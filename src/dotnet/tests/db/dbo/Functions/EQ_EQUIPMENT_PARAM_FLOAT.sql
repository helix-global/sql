create function [dbo].[EQ_EQUIPMENT_PARAM_FLOAT](@EqID int, @ParamID int)
returns float as 
begin

  declare @val sql_variant
  set @val = dbo.EQ_EQUIPMENT_PARAM(@EqID, @ParamID)
  if @val is null
    return null
    
  declare @valstr varchar(200)
  set @valstr = CAST(@val as varchar(200))
  set @valstr = REPLACE(@valstr,',','.')
  
  
  if isnumeric(@valstr) = 1
     return cast(@valstr as float);
  
  return null

end