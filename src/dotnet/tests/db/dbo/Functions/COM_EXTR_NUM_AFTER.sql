CREATE function [dbo].[COM_EXTR_NUM_AFTER](@aInStr nvarchar(max), @aAfterStr nvarchar(50))
returns int with schemabinding as 
begin
  declare @res int
  
  declare @tempStr nvarchar(max)
  set @tempStr = reverse(@aInStr)
  
  declare @tempKey nvarchar(50)
  set @tempKey = reverse(@aAfterStr)

  declare @keyPos int
  set @keyPos = charindex(@tempKey,@tempStr)
  
  if @keyPos > 0
    set @tempStr = substring(@tempStr,1,@keyPos-1)

  declare @tempStrOut nvarchar(max) = ''

  declare @i int
  declare @j nvarchar(1)
  set @i = 1
  while (@i <= LEN(@tempStr))
  begin
     set @j = SUBSTRING(@tempStr,@i,1) 
     if @j = '0' or @j = '1' or @j = '2' or @j = '3' or @j = '4' or @j = '5' or @j = '6' or @j = '7' or @j = '8' or @j = '9'
       set @tempStrOut = @tempStrOut + @j
     set @i = @i + 1  
  end
  
  set @tempStrOut = reverse(@tempStrOut)
  
  return convert(int,@tempStrOut)
  
end