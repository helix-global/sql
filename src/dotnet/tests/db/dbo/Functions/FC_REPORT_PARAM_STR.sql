CREATE function [dbo].[FC_REPORT_PARAM_STR](@aRepID int,@aParamID int)
returns nvarchar(max) as 
begin

  declare @val sql_variant
  set @val = dbo.FC_REPORT_PARAM(@aRepID,@aParamID)
  if @val is null
    return null
    
  declare @dataType int
  select @dataType = A.DATATYPE from FC_FAILUREPARAMS A with (nolock) where A.ID = @aParamID
  if @dataType = 4
    return convert(nvarchar,@val,104)

  return cast(@val as nvarchar(max))

end