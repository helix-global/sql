create function [dbo].[COM_STR2TABLE_STR_DELIM2] (@aList nvarchar(max),@aDelimeter nvarchar(max))
returns @res table (ITEM nvarchar(max) )
as 
begin
/* 
 от первой версии отличается тем, что не применяет ltrim(rtrim()) к результатам
 некоторые значения (например имена параметров имеют пробелы в начале либо в конце) 
*/
   
   if (@aList is null) return
   
   declare @tmp nvarchar(max)
   set @tmp = @aDelimeter+@aList+@aDelimeter
   declare @one nvarchar(max)
   
   declare @i int = 0, @j int = 0
   while 1=1
   begin
   
      set @i = CHARINDEX(@aDelimeter,@tmp,@i)
      if @i = 0
        break
      set @i = @i + len(@aDelimeter)
      set @j = CHARINDEX(@aDelimeter,@tmp,@i)
      if @j < @i
        break
   
      set @one = SUBSTRING(@tmp,@i,@j-@i)
      if @one <> ''
        insert into @res (ITEM) values (@one)
       
   end

   return
end