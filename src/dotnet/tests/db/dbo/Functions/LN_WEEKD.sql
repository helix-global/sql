CREATE function [dbo].[LN_WEEKD](@aDBeg datetime,@aNow datetime, @aMode int)
returns nvarchar(100) with schemabinding as 
begin


   declare @res nvarchar(100)
   declare @dEnd datetime = dateadd(day,6,@aDBeg)
   declare @dNextWeek datetime = dateadd(day,7,@aNow)
   
   set @res = convert(nvarchar,@aDBeg,104) + ' - ' + convert(nvarchar,@dEnd,104)
   if ((@aNow > @aDBeg) and  (@aNow < @dEnd))
      set @res = @res + ' (current week)'
   else if ((@dNextWeek > @aDBeg) and  (@dNextWeek < @dEnd))
      set @res = @res + ' (next week)'
     
   return @res  

end