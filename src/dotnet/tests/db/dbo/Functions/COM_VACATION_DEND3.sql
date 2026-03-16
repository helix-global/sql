CREATE function [dbo].[COM_VACATION_DEND3](@aID int)
returns datetime as 
begin
  /* версия 3 учитывает смены в вариантах forenoon, afternoon - определяет середину смены */  
  declare @res datetime 
  
  declare @dbeg datetime
  declare @dend datetime
  declare @vtype int
  declare @ptype int
  declare @shDuration int
  declare @shStart datetime
  declare @EmplID int
  declare @specialShort int  
   
   select @dbeg = cast(A.DBEG as date)
        , @dend = cast(A.DEND as date)
        , @vtype = A.VACATIONTYPE
        , @ptype = isnull(A.PERIODTYPE,1)
        , @shStart = A.SHORTSTART
        , @shDuration = A.SHORTDURATION
        , @EmplID = A.EMPLID
        , @specialShort = ISNULL(A.P_SPLEAVE_SHORT,0)
   from COM_VACATION A with (nolock)
   where A.ID = @aID
   
   if @vtype in (30,80,200) /*short absence, int.appoin*/
   begin

      set @res = cast(@dbeg as date)   
      set @res = @res + cast(cast(@shStart as time) as datetime)
      set @res = dateadd(minute,@shDuration,@res)
   
   end
   else if @vtype = 70 and @specialShort = 1
   begin
	
      set @res = cast(@dbeg as date)   
      set @res = @res + cast(cast(@shStart as time) as datetime)
      set @res = dateadd(minute,@shDuration,@res)
	
   end  
   else 
   begin
   
     if @ptype = 1 /*full*/
     begin
        set @res = isnull(@dend,@dbeg)
        set @res = dateadd(hour,24,@res)
        set @res = dateadd(hour,3,@res) /* вторая смена может захватить до 3-х часов сл.дня */
     end     
     else if @ptype = 2 /*forenoon*/       
     begin
        set @res = cast(@dbeg as date)   
        set @res = dbo.COM_TURN_MIDDLE(@EmplID,@res)
     end     
     else if @ptype = 3 /*afternoon*/
     begin
        set @res = @dbeg
        set @res = dateadd(hour,24,@res) 
        set @res = dateadd(hour,3,@res) /* вторая смена может захватить до 3-х часов сл.дня */
     end
     
   end 
   
   return @res
  
end