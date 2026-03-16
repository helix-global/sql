create function [dbo].[FC_REPORT_PARAM_INT](@aRepID int,@aParamID int)
returns int as 
begin
  declare @val sql_variant
  set @val = dbo.FC_REPORT_PARAM(@aRepID,@aParamID)
  if @val is null
    return null
    
  
  declare @valstr varchar(200)
  declare @valBigInt bigint  
  
  set @valstr = CAST(@val as varchar(200))
  set @valstr = REPLACE(@valstr,',','.')
    
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