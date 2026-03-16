CREATE FUNCTION dbo.PR_PARAM_CONVERT (@value sql_variant, @type int)
RETURNS sql_variant
begin

  if (@type = 2) /*DateTime*/
  begin

    if sql_variant_property(@value,'BaseType') <> 'datetime'
    begin
      return convert(datetime, @value, 104)
    end

  end

  return @value

end