create function [dbo].[PR_OPTIONBOM_NAME_FROM_N](@aString nvarchar(150),@aN int,@aFromN int)
returns nvarchar(150) as 
begin
   
   declare @res nvarchar(150)
   set @res = null
   declare @fromString nvarchar(150)
   declare @toString nvarchar(150)
   
   set @fromString = ltrim(rtrim(str(@aFromN))) + '#'
   set @toString = ltrim(rtrim(str(@aN + @aFromN - 1))) + '#'
      
   if charindex(@fromString,@aString) > 0
     set @res = replace(@aString,@fromString,@toString) 
      
   if @res is not null
     return @res
     

   set @fromString = '#' + ltrim(rtrim(str(@aFromN))) 
   set @toString = '#' + ltrim(rtrim(str(@aN + @aFromN - 1)))
      
   if charindex(@fromString,@aString) > 0
     set @res = replace(@aString,@fromString,@toString) 
      
   if @res is not null
     return @res

   set @fromString = ltrim(rtrim(str(@aFromN)))  
   set @toString =  ltrim(rtrim(str(@aN + @aFromN - 1)))
      
   if charindex(@fromString,@aString) > 0
     set @res = replace(@aString,@fromString,@toString) 
      
   return @res

end