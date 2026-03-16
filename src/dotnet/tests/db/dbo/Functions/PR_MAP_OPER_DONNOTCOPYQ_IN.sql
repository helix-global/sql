create function [dbo].[PR_MAP_OPER_DONNOTCOPYQ_IN](@aRevOperID int)
returns int as 
begin

  declare @res int
  
  select @res = isnull(DONNOTCOPYQ_IN,0) from PR_MAP_OPER A with (nolock) where A.ID = @aRevOperID
  
  return @res;
  
end