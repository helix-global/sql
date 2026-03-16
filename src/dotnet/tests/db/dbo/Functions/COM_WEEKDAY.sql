create function [dbo].[COM_WEEKDAY](@WeekDD datetime,@dayN int)
returns date with schemabinding as 
begin
   /*
   возвращает дату дня недели по любой дате из этой недели и номеру дня (1-понедельник)
   */
   declare @res date
   declare @dayOfWeek int = (@@datefirst+datepart(weekday,@WeekDD)-2)%7+1;
   declare @weekMonday datetime = dateadd(day,1-@dayOfWeek,@WeekDD) 
   
   set @res = dateadd(day,@dayN-1,@weekMonday)

   return @res 

end