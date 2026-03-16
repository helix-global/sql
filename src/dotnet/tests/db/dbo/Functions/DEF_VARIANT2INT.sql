create function [dbo].[DEF_VARIANT2INT](@val sql_variant)
returns int with schemabinding as 
begin
   
    return cast(@val as int)
  
end