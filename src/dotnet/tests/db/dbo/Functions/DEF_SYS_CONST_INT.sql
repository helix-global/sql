create function [dbo].[DEF_SYS_CONST_INT](@aLabel nvarchar(100), @nullValue int)
returns int as 
begin
  declare @res int
  select @res = A.VALUEINT from DEF_SYSCONST A with (nolock) where A.LABEL = @aLabel
  if (@nullValue is not null)
    set @res = isnull(@res,@nullValue)
  return @res;
end