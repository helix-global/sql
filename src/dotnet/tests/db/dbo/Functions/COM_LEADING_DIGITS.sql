create function [dbo].[COM_LEADING_DIGITS](@aInStr nvarchar(250))
returns nvarchar(250) with schemabinding as 
begin
  declare @res nvarchar(250)
  
  declare @tempStr nvarchar(250) = ''

  declare @i int
  declare @j nvarchar(1)
  set @i = 1
  while (@i < LEN(@aInStr))
  begin
     set @j = SUBSTRING(@aInStr,@i,1) 
     if @j = '.' or @j = '0' or @j = '1' or @j = '2' or @j = '3' or @j = '4' or @j = '5' or @j = '6' or @j = '7' or @j = '8' or @j = '9'
       set @tempStr = @tempStr + @j
     else
       break  
     set @i = @i + 1  
  end
  
  return @tempStr
  
end