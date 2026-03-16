CREATE function [dbo].[COM_STR_EMAIL_2TABLE] (@aList nvarchar(max))
returns @res table (EMAIL nvarchar(max), NAME nvarchar(max), ITEMRAW nvarchar(max))
as 
begin
   
   if (@aList is null) return
   
   declare @tmp nvarchar(max)
   set @tmp = ','+@aList+','
   declare @one nvarchar(max)
   
   declare @zi int
   declare @zj int
   declare @oneEmail nvarchar(max)
   declare @oneName nvarchar(max)
   
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
      begin
          set @zi = 0
          set @zj = 0
          set @zi = CHARINDEX('<',@one)
          set @zj = CHARINDEX('>',@one)
          if (@zi > 0 and @zj > @zi)
          begin
            
            set @oneEmail = ltrim(rtrim(SUBSTRING(@one,@zi+1,@zj-@zi-1)))
            set @oneName = ltrim(rtrim(SUBSTRING(@one,1,@zi-1)))
            
            if len(@oneName) = 0
              set @oneName = @oneEmail
            
            insert into @res (EMAIL,NAME,ITEMRAW) values (@oneEmail,@oneName,@one)
            
          end
          else
          begin
          
            insert into @res (EMAIL,NAME,ITEMRAW) values (@one,@one,@one)
            
          end          
        
      end
       
   end

   return
end