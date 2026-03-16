CREATE function [dbo].PR_NEEDAUTOPOSTPONE(@setting datetime)
returns int as 
begin
  
   if @setting is null
     return 0
  
   declare @now datetime = getdate()
   declare @nowDate date = cast(@now as date)
   declare @nowTime time = cast(@now as time)
   
   declare @settTime time = cast(@setting as time)
   
   if datepart(hour,@settTime) <= 3
   begin
       if datepart(hour,@nowTime) <= 4 and @nowTime > @settTime
          return 1
          
       return 0  
   end
   
   if @nowTime > @settTime
      return 1 

   return 0

end