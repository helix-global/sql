
create function [dbo].[DEF_SYS_CONST_DEC](@aLabel nvarchar(100), @nullValue decimal(18,1))
returns decimal(18,1) as 
begin
  declare @res decimal(18,1)
  select @res = A.VALUEDEC from DEF_SYSCONST A with (nolock) where A.LABEL = @aLabel
  if (@nullValue is not null)
    set @res = isnull(@res,@nullValue)
  return @res;
end