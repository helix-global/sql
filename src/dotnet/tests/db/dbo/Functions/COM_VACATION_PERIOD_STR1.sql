
-- Отображение коротких отсутсвий вида "10.02.2021 8:00-9:30"

CREATE function [dbo].[COM_VACATION_PERIOD_STR1](@aID int,@aMode  int)
returns nvarchar(max) as 
begin
  declare @res nvarchar(max)
  
  declare @dbeg datetime
  declare @dend datetime
  declare @vtype int
  declare @ptype int
  declare @shDuration int
  declare @shortStart datetime
  declare @specialShort int  
   
   select @dbeg = A.DBEG
        , @dend = A.DEND
        , @vtype = A.VACATIONTYPE
        , @ptype = A.PERIODTYPE
        , @shDuration = A.SHORTDURATION
        , @shortStart = A.SHORTSTART
        , @specialShort = ISNULL(A.P_SPLEAVE_SHORT,0)
   from COM_VACATION A with (nolock)
   where A.ID = @aID
   
   set @res = ''
   
   if @dend is null or @dbeg = @dend
   begin
     set @res = @res + convert(nvarchar,@dbeg,104)
     if @aMode = 10 and @vtype not in (30 ,80,200)
     begin
        if isnull(@ptype,1) = 2 
           set @res = @res + ' Forenoon'
        else if isnull(@ptype,1) = 3 
           set @res = @res + ' Afternoon'
        else
           set @res = @res + ' Full day'
     end
   end
   else
     set @res = @res + convert(nvarchar,@dbeg,104)+' - '+convert(nvarchar,@dend,104)
   
   if @vtype in (30,80,200)
   begin
   
     set @res = @res + ' '+substring(convert(nvarchar,@shortStart,108),1,5)
				+'-'
				--+convert(nvarchar,@shDuration)
				+substring(convert(nvarchar ,convert(time, DATEADD(minute, @shDuration, convert(nvarchar,@shortStart,108)))),1,5)
   
   end
   
   if @vtype = 70 and @specialShort = 1
   begin
	
     set @res = @res + ' '+substring(convert(nvarchar,@shortStart,108),1,5)
				+'-'
				--+convert(nvarchar,@shDuration)
				+substring(convert(nvarchar ,convert(time, DATEADD(minute, @shDuration, convert(nvarchar,@shortStart,108)))),1,5)
	
   end     
   
   
   return @res
  
end