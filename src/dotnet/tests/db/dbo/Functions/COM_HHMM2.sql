CREATE function [dbo].[COM_HHMM2](@aDate datetime)
returns nvarchar(20) with schemabinding as 
begin
   /* возвращает время в формате HH:mm  48:03 
    v.2 работает с часами > 24
    дни * 24 отсчитываются от 19000101
   */
   
   declare @hh int = datepart(hour,@aDate) + (24 * datediff(day,'19000101',@aDate))
   declare @mm int = datepart(minute,@aDate)
   
   declare @h nvarchar(14) = ltrim(rtrim(str(@hh)))
   declare @m nvarchar(2) = ltrim(rtrim(str(@mm)))
   
   if @hh < 10
     set @h = '0' + @h

   if @mm < 10
     set @m = '0' + @m

   
   return @h+':'+@m

  
end