create function [dbo].[COM_YYMDD](@aDate datetime)
returns nvarchar(5) as 
begin
   /* возвращает дату в формате YYMDD год, месяц (9,A,B,С), день */
   
   declare @yy int = year(@aDate)
   declare @mm int = month(@aDate)
   declare @dd int = day(@aDate)
   
   declare @y nvarchar(10) = ltrim(rtrim(str(@yy)))
   declare @m nvarchar(10) = ltrim(rtrim(str(@mm)))
   declare @d nvarchar(10) = ltrim(rtrim(str(@dd)))
   
   if @mm = 10
     set @m = 'A'
   else if @mm = 11
     set @m = 'B'
   else if @mm = 12
     set @m = 'C'
   
   set @y = SUBSTRING(@y,3,2);
   
   if @dd < 10
     set @d = '0' + @d
   
   declare @res nvarchar(12)
   set @res = @y+@m+@d
   return @res

  
end