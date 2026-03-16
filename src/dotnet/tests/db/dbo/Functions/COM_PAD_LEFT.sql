CREATE function [dbo].[COM_PAD_LEFT](@aInStr nvarchar(max), @aPadChar nvarchar(1), @aNeedLen int)
returns nvarchar(max) with schemabinding as  
begin
  declare @res nvarchar(max)
  
  set @res = ltrim(rtrim(@aInStr))
  
  declare @i int
  set @i = @aNeedLen - LEN(@res)
  if (@i > 0)
    set @res = REPLICATE(@aPadChar, @i) + @res 
  
  return @res;
end