CREATE function [dbo].[COM_EXTR_NUM](@aInStr nvarchar(max), @aPos int, @aLen int)
returns int with schemabinding as 
begin
  declare @res int
  
  declare @tempStr nvarchar(50)
  set @tempStr = SUBSTRING(@aInStr,@aPos,@aLen)
  set @tempStr = ltrim(rtrim(@tempStr))

  declare @i int
  declare @j nvarchar(1)
  set @i = 1
  while (@i < LEN(@tempStr))
  begin
     set @j = SUBSTRING(@tempStr,@i,1) 
     if @j <> '0' and @j <> '1' and @j <> '2' and @j <> '3' and @j <> '4' and @j <> '5' and @j <> '6' and @j <> '7' and @j <> '8' and @j <> '9'
       return null
     set @i = @i + 1  
  end
  
  return convert(int,@tempStr)
  
end