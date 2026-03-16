create function [dbo].[COM_CUT_STRING](@aString nvarchar(max),@aLen int,@aMode int)
returns nvarchar(max) with schemabinding as 
begin

   if @aString is null
     return null
    
   if @aLen is null
     return @aString 

   if len(@aString) < (@aLen + 4)
     return @aString
     
   return substring(@aString,0,@aLen) + ' ...'  

end