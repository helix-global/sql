create function [dbo].[COM_STR2TABLE_STR_DELIM] (@aList nvarchar(max),@aDelimeter nvarchar(max))
returns @res table (ITEM nvarchar(max) )
as 
begin
   
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
   
      set @one = ltrim(rtrim(SUBSTRING(@tmp,@i,@j-@i)))
      if @one <> ''
        insert into @res (ITEM) values (@one)
       
   end

   return
end