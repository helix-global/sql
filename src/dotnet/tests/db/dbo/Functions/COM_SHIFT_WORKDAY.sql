CREATE function [dbo].[COM_SHIFT_WORKDAY](@dd datetime,@aCalendarID int,@mode int)
returns datetime as 
begin
   /*
   сдвигает день 
   @mode = 1 - вперед +1
   @mode = 2 - назад  -1
   до тех пор, пока день не попадет на рабочий день 
   */
   
   
   declare @result datetime = @dd
   
   if @mode in (1,2)
   begin
	   declare @i int = 0
	   declare @direction int = 1
	   if @mode = 2
		 set @direction = -1
	   
	   while dbo.COM_IS_WORKDAY(@result,@aCalendarID) <> 1
	   begin
		  set @result = dateadd(day,@direction,@result)
		  set @i = @i + 1
		  if @i > 100
			return null /* что-то не так, а raiseror нельзя*/
	   end
   end   
     
   return @result  

end