CREATE function [dbo].[COM_HHMM](@aDate datetime)
returns nvarchar(5) with schemabinding as 
begin
   /* возвращает время в формате HH:mm  21:03 */
   
   declare @hh int = datepart(hour,@aDate)
   declare @mm int = datepart(minute,@aDate)
   
   declare @h nvarchar(2) = ltrim(rtrim(str(@hh)))
   declare @m nvarchar(2) = ltrim(rtrim(str(@mm)))
   
   if @hh < 10
     set @h = '0' + @h

   if @mm < 10
     set @m = '0' + @m

   
   return @h+':'+@m

  
end