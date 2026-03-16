CREATE function [dbo].[DEF_LOG_SPENDTIME](@aEventText nvarchar(max))
returns decimal(16,6) with schemabinding as 
begin

   declare @lastLine nvarchar(max) = reverse(@aEventText)
   declare @i int 
   set @i = charindex( char(10), @lastLine , 2 )
   set @lastLine = substring(@lastLine,0,@i)
   set @lastLine = replace(@lastLine,'s','')
   set @lastLine = reverse(@lastLine)
   set @lastLine = replace(@lastLine,',','.')
   set @lastLine = replace(@lastLine,char(13),'')
   set @lastLine = replace(@lastLine,char(10),'')
   set @lastLine = ltrim(rtrim(@lastLine))
   
   if len(@lastLine) = 0
     return null
   if isnumeric(@lastLine) = 0
     return null
     
   declare @res decimal(16,6)
   
   set @res = cast(@lastLine as decimal(16,6))
   
   return @res

end