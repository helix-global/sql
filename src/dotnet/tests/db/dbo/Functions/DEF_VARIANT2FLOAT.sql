CREATE function [dbo].[DEF_VARIANT2FLOAT](@val sql_variant)
returns float with schemabinding as 
begin
  if @val is null return null
  
  declare @valstr varchar(200)
  set @valstr = CAST(@val as varchar(200))
  set @valstr = REPLACE(@valstr,',','.')
  
  return cast(@valstr as float);  
  
end