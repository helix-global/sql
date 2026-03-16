CREATE function [dbo].[COM_LANG_EN](@aStr nvarchar(max))
returns nvarchar(max) WITH SCHEMABINDING as 
begin
  declare @res nvarchar(max)
  set @res = @aStr

  declare @i int
  set @i = CHARINDEX('[',@res)
  if @i > 0 
  begin
    if (SUBSTRING(@res,@i+3,1) = '=') or (SUBSTRING(@res,@i+2,1) = '=')
      set @res = SUBSTRING(@res,1,@i-1)
  end
  
  return @res;
end