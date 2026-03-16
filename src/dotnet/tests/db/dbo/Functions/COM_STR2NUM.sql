create function [dbo].[COM_STR2NUM](@aInStr nvarchar(50))
returns bigint with schemabinding as 
begin
  declare @res bigint
  
  declare @tempStr nvarchar(50) = ''

  declare @i int
  declare @j nvarchar(1)
  set @i = 1
  while (@i < LEN(@aInStr))
  begin
     set @j = SUBSTRING(@aInStr,@i,1) 
     if @j = '0' or @j = '1' or @j = '2' or @j = '3' or @j = '4' or @j = '5' or @j = '6' or @j = '7' or @j = '8' or @j = '9'
       set @tempStr = @tempStr + @j
     set @i = @i + 1  
  end
  
  return convert(bigint,@tempStr)
  
end