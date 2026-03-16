create function [dbo].[COM_STR2TABLE_INT_3COL] (@aList nvarchar(max))
returns @res table (ID int ,ID2 int, ID3 int)
as 
begin
   
   if (@aList is null) return
   
   declare @tmp nvarchar(max)
   set @tmp = ','+@aList+','
   declare @one nvarchar(200)
   declare @one2 nvarchar(200)
   declare @one3 nvarchar(200)
   
   declare @i int = 0, @j int = 0
   while 1=1
   begin
   
      set @i = CHARINDEX(',',@tmp,@i)
      if @i = 0
        break
      set @i = @i +1
      set @j = CHARINDEX(',',@tmp,@i)
      if @j < @i
        break
   
      set @one = ltrim(rtrim(SUBSTRING(@tmp,@i,@j-@i)))
      
      set @i = CHARINDEX(',',@tmp,@i)
      if @i = 0
        break
      set @i = @i +1
      set @j = CHARINDEX(',',@tmp,@i)
      if @j < @i
        break
      
      set @one2 = ltrim(rtrim(SUBSTRING(@tmp,@i,@j-@i)))      
      
      set @i = CHARINDEX(',',@tmp,@i)
      if @i = 0
        break
      set @i = @i +1
      set @j = CHARINDEX(',',@tmp,@i)
      if @j < @i
        break
      
      set @one3 = ltrim(rtrim(SUBSTRING(@tmp,@i,@j-@i)))      
      
      if @one <> '' and @one2 <> '' and @one3 <> ''
        insert into @res (ID,ID2,ID3) values (CONVERT(int,@one),CONVERT(int,@one2),CONVERT(int,@one3))
       
   end

   return
end