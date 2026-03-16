-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-03-26
-- Description: Converts specified value to float type.
-- =============================================
-- KB4680:2024-03-26: Initial update.
CREATE function [dbo].[COM_CONVERT_TO_FLOAT](@Value sql_variant)
returns float
as
begin
  if @Value is null return null
  declare @ValueBaseType sysname = cast(SQL_VARIANT_PROPERTY(@Value,'BaseType') as sysname)

  if @ValueBaseType = 'int'      return cast(@Value as int)
  if @ValueBaseType = 'bit'      return cast(@Value as bit)
  if @ValueBaseType = 'decimal'  return cast(@Value as decimal(38))
  if @ValueBaseType = 'float'    return cast(@Value as float)
  if @ValueBaseType = 'datetime' return convert(float,cast(@Value as datetime),0)
  if @ValueBaseType = 'nvarchar'
  begin
    declare @ValueS varchar(max) = ltrim(rtrim(cast(@Value as varchar(max))))
    declare @ValueF float = null
    set @ValueF = try_cast(@ValueS as float)
    if @ValueF is not null return @ValueF
  end
  return null
end