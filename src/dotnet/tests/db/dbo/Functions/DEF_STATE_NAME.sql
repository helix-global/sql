create function [dbo].[DEF_STATE_NAME](@aStateOID int)
returns nvarchar(150) as 
begin
  declare @res nvarchar(150)
  select @res = A.NAME from DEF_CLASS_STATES A with (nolock) where A.OID = @aStateOID
  return @res;
end