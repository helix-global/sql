CREATE function [dbo].[COM_CUT_LAST](@aString nvarchar(max),@aLastChar nvarchar(20))
returns nvarchar(max) with schemabinding as 
begin

   if @aString is null
     return null
    
   if @aLastChar is null
     return @aString 

   declare @res nvarchar(max)
   set @res = RTRIM(@aString)
   
   declare @i int = LEN(@aLastChar)
   
   if RIGHT(@res,@i) = @aLastChar
      set @res = left(@res,len(@res)-@i)
      
    return @res  

end