create function [dbo].[PR_GET_INDEXED_VALUE](@value sql_variant)
returns nvarchar(250) as
begin
  
  declare @type sql_variant = sql_variant_property(@value, 'BaseType');
  
  declare @result nvarchar(250) =
    case @type
  
    	when 'varchar' then (case when len(cast(@value as varchar(251))) <= 250 then cast(@value as nvarchar(250)) else null end)
      when 'nvarchar' then (case when len(cast(@value as nvarchar(251))) <= 250 then cast(@value as nvarchar(250)) else null end)
      when 'int' then cast(@value as nvarchar(250))
      when 'float' then cast(@value as nvarchar(250)) --convert decimal point
      when 'decimal' then cast(@value as nvarchar(250)) --convert decimal point
      when 'bit' then cast(@value as nvarchar(250))

      when 'datetime' 
        then case when datediff(year, cast(@value as datetime), {d '1970-01-01'}) < 62 
              then cast(datediff(second,{d '1970-01-01'}, cast(@value as datetime)) as nvarchar(250)) --unix format
              else null
             end
    
    	else null
  
    end

    return @result;

end