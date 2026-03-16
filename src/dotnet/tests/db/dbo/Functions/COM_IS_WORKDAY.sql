CREATE function [dbo].[COM_IS_WORKDAY](@dd datetime,@aCalendarID int)
returns int as 
begin
   
   declare @dayOfWeek int
   set @dayOfWeek = (@@datefirst+datepart(weekday,@dd)-2)%7+1; /*DATEPART(DW,@dd); */
   
   declare @result int
   set @result = 0
   if @dayOfWeek < 6
      set @result = 1
     
   declare @day date
   set @day = cast (@dd as date) 
   
   declare @cStatus int
   
   select @cStatus = A.DAYSTATUS from COM_CALENDAR A with (nolock) where A.CALENDAR = @aCalendarID and A.DDAY = @day 
   
   if (@result = 1 and @cStatus = 2)
     return 0
   
   if (@result = 0 and @cStatus = 1)
     return 1
     
     
   return @result  

end