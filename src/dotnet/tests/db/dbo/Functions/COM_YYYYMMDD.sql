create function [dbo].[COM_YYYYMMDD](@aDate datetime)
returns nvarchar(8) as 
begin
   /* возвращает дату в формате YYYYMMDD год, месяц, день */
   
   declare @yy int = year(@aDate)
   declare @mm int = month(@aDate)
   declare @dd int = day(@aDate)
   
   declare @y nvarchar(4) = ltrim(rtrim(str(@yy)))
   declare @m nvarchar(2) = dbo.COM_ADD_LEADING_ZEROES(@mm,2)
   declare @d nvarchar(2) = dbo.COM_ADD_LEADING_ZEROES(@dd,2)
   
   
   
   declare @res nvarchar(8)
   set @res = @y+@m+@d
   return @res

  
end