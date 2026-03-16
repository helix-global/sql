CREATE function [dbo].[COM_EXTR_WORD](@aInStr nvarchar(max), @aPos int, @aDelim nvarchar(1))
returns nvarchar(max) with schemabinding as 
begin
  declare @res nvarchar(max)
  
  declare @i int
  declare @ii int = 0
  declare @j nvarchar(1)
  set @i = 1
  while (@i <= LEN(@aInStr))
  begin
     set @j = SUBSTRING(@aInStr,@i,1) 
     set @i = @i + 1
     if @j = @aDelim
       set @ii = @ii + 1
     else if @ii = @aPos
       set @res = isnull(@res,'') + @j   
     if @ii > @aPos
       break
  end
  
  return @res
  
end