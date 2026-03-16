create function [dbo].[DEF_CLASS_ACCESS](@aClassOID int, @aLabel nvarchar(200), @aAction int, @aDate datetime, @UserID int)
returns int as 
begin
  declare @res int
  if @aLabel is null
    select @res = dbo.DEF_F_ACCESS(A.ARC,null,@aAction,@aDate,@UserID,0) from DEF_CLASSES A with (nolock) where A.OID = @aClassOID
  else
    select @res = dbo.DEF_F_ACCESS(A.ARC,null,@aAction,@aDate,@UserID,0) from DEF_CLASSES A with (nolock) where A.LABEL = @aLabel
  return @res;
end