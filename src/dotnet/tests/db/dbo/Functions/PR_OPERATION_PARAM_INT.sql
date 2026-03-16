create function [dbo].[PR_OPERATION_PARAM_INT](@OperID int, @ParamID int)
returns int as 
begin
  declare @val sql_variant
  declare @valStr varchar(100)
  declare @valBigInt bigint  
  
  set @val = dbo.PR_OPERATION_PARAM(@OperID, @ParamID)
  
  if @val is null
    return null
    
  set @valStr = cast(@val as varchar)
  if isnumeric(@valStr) = 1
  begin
     if len(@valStr) > 12 
        return null
     if CHARINDEX(',', @valStr) > 0
        return null
     if CHARINDEX('.', @valStr) > 0
        return null
     if CHARINDEX('E', @valStr) > 0
        return null
     set @valBigInt = cast(@valStr as bigint)
     if (@valBigInt > 2147483647)
        return null     
     if (@valBigInt < -2147483648)
        return null     
     return cast(@valBigInt as int)
  end
    
  return null
end