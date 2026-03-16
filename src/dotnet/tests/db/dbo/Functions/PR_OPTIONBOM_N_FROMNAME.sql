CREATE function [dbo].[PR_OPTIONBOM_N_FROMNAME](@aString nvarchar(150))
returns int as 
begin

   declare @i int
   declare @si nvarchar(50)
   
   set @i = 1
   while @i < 50
   begin
      set @si = ltrim(rtrim(str(@i)))
      set @si = '%'+@si+'#%'
      if @aString like @si
         return @i
      set @i = @i + 1   
   end

   set @i = 1
   while @i < 50
   begin
      set @si = ltrim(rtrim(str(@i)))
      set @si = '%#'+@si+'%'
      if @aString like @si
         return @i
      set @i = @i + 1   
   end

   set @i = 1
   while @i < 50
   begin
      set @si = ltrim(rtrim(str(@i)))
      set @si = '%'+@si+'%'
      if @aString like @si
         return @i
      set @i = @i + 1      
   end
      
   return null

end