CREATE function [dbo].[COM_STR_DEL_BEFORE](@aString nvarchar(max),@aBeforeString nvarchar(50))
returns nvarchar(max) as 
begin

   if @aString is null
     return null
    
   if @aBeforeString is null
     return @aString 

   declare @pos int = charindex(@aBeforeString,@aString)
   if @pos > 0
      return substring(@aString,@pos+1,999999)
      
   return @aString   

end