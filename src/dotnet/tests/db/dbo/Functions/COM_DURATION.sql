CREATE function [dbo].[COM_DURATION](@aDBeg datetime,@aDEnd datetime)
returns decimal(12,2) with schemabinding as 
begin

   if @aDBeg is null
     return null

   declare @res decimal(12,2)
   set @res = datediff(s,@aDBeg,isnull(@aDEnd,getdate())) 
   set @res = @res / 60
     
   return @res  

end