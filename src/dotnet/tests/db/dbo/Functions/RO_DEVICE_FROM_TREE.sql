create function dbo.RO_DEVICE_FROM_TREE(@DeviceID int, @BomTree nvarchar(max))
returns int as 
begin
  
   declare @res int
  
   if (@BomTree is null) return null
   
   set @res = @DeviceID
   
   declare @tmp nvarchar(max)
   set @tmp = ','+@BomTree+','
   declare @one nvarchar(200)
   declare @oneint int
   
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
        set @oneint = CONVERT(int,@one)
        set @res = dbo.PR_DEVICE_BOMITEM(@res,@oneint)
        if @res is null
          return null
      end  
       
   end
  
  return @res
  
end