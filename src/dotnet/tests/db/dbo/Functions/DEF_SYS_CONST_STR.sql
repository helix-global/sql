CREATE function [dbo].[DEF_SYS_CONST_STR](@aLabel nvarchar(100), @nullValue nvarchar(200))
returns nvarchar(200) as 
begin
  declare @res nvarchar(200)
  select @res = A.VALUESTR from DEF_SYSCONST A with (nolock) where A.LABEL = @aLabel
  if (@nullValue is not null)
    set @res = isnull(@res,@nullValue)
  return @res;
end