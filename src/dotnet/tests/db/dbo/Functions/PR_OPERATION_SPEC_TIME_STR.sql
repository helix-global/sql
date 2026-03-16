CREATE function [dbo].[PR_OPERATION_SPEC_TIME_STR](@tcAction int, @tcMinute int)
returns nvarchar(50)
as
begin
   if ISNULL(@tcAction,0) = 0
     return null
   else if @tcAction = 1
     return '= '+ltrim(str(@tcMinute))+ ' min'  
   else if @tcAction = 2
     return '+ '+ltrim(str(@tcMinute))+ ' min'  
     
   return null
end;