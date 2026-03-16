CREATE function [dbo].[COM_WORKPERIOD_LEN](@aTurnN int, @aDbeg datetime, @aDend datetime)
returns int with schemabinding as 
begin
   /* возвращает длину периода из рабочего графика в минутах с учетом перехода за полночь */
   declare @res int
   
   declare @db time = cast(@aDbeg as time)
   declare @de time = cast(@aDend as time)
   
   if @db < @de
   begin
   
     set @res = datediff(mi,@db,@de)
     
   end
   else if @db > @de 
   begin

     set @res = datediff(mi,'00:00:00',@de) + datediff(mi,@db,'23:59:00') + 1 

   end
   
   return @res
end