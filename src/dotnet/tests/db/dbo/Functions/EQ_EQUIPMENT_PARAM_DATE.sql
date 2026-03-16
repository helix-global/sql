CREATE function [dbo].[EQ_EQUIPMENT_PARAM_DATE](@EqID int, @ParamID int)
returns datetime as 
begin

  declare @val sql_variant
  set @val = dbo.EQ_EQUIPMENT_PARAM(@EqID, @ParamID)
  if @val is null
    return null
    
  if SQL_VARIANT_PROPERTY(@val,'BaseType')  = 'datetime'
     return convert(date,@val)   
     
  declare @dds nvarchar(50)
  declare @dd date
  set @dds = cast(@val as nvarchar(50)) 
  set @dds = ltrim(rtrim(@dds))
  if len(@dds) = 8  /* 01.01.50 */
  begin
    set @dd = convert(date,@dds,4)
    return @dd
  end
  else
  begin
    set @dd = convert(date,@dds,104)
    return @dd
  end  

  
  return null

end