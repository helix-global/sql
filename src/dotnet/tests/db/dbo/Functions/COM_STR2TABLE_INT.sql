CREATE function [dbo].[COM_STR2TABLE_INT] (@aList nvarchar(max))
returns @res table (ID int )
as 
begin
   
   if (@aList is null) return
   
   declare @tmp nvarchar(max)
   set @tmp = ','+@aList+','
   declare @one nvarchar(200)
   
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
      if @one <> ''
        insert into @res (ID) values (CONVERT(int,@one))
       
   end

   return
end
GO
GRANT SELECT
    ON OBJECT::[dbo].[COM_STR2TABLE_INT] TO [IPG-DOMAIN\IPGL_Integr_MSCRM]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[COM_STR2TABLE_INT] TO [EMEA\DEPCS]
    AS [dbo];

