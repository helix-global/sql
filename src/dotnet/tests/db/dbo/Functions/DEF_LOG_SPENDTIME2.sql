CREATE function [dbo].[DEF_LOG_SPENDTIME2](@aEventText nvarchar(max))
returns decimal(16,6) with schemabinding as 
begin

   declare @Line nvarchar(max) = @aEventText
   declare @i int 
   set @i = charindex( 'Time spend', @Line )
   if @i > 0
     set @Line = substring(@Line,@i+10,9)
   
   set @Line = ltrim(rtrim(@Line))
   
   if len(@Line) = 0
     return null
   if isnumeric(@Line) = 0
     return null
     
   set @Line = replace(@Line,',','.')  
   set @Line = replace(@Line,'e','')  
     
   declare @res decimal(16,6)
   
   set @res = cast(@Line as decimal(16,6))
   
   return @res

end