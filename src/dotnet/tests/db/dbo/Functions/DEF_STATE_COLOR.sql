create function [dbo].[DEF_STATE_COLOR](@aStateOID int)
returns int as 
begin
  declare @res int
  select @res = A.STATECOLOR from DEF_CLASS_STATES A with (nolock) where A.OID = @aStateOID
  return @res;
end