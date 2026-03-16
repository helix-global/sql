create function [dbo].[DEF_CLASS_ARC](@aOID int,@aLabel nvarchar(200))
returns int as 
begin
  declare @res int
  if @aLabel is null
    select @res = A.ARC from DEF_CLASSES A with (nolock) where A.OID = @aOID
  else
    select @res = A.ARC from DEF_CLASSES A with (nolock) where A.LABEL = @aLabel
  return @res;
end