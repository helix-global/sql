CREATE function [dbo].[COM_VACATION_DBEG3](@aID int)
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
   
   select @dbeg = A.DBEG
        , @dend = A.DEND
        , @vtype = A.VACATIONTYPE
        , @ptype = A.PERIODTYPE
        , @shStart = A.SHORTSTART
        , @shDuration = A.SHORTDURATION
        , @EmplID = A.EMPLID
        , @specialShort = ISNULL(A.P_SPLEAVE_SHORT,0)
   from COM_VACATION A with (nolock)
   where A.ID = @aID
   
   set @res = cast(@dbeg as date)
   
   if @vtype in (30,80,200) /*short absence, int.appoin*/
   begin
   
      set @res = @res + cast(cast(@shStart as time) as datetime)
   
   end
   else if @vtype = 70 and @specialShort = 1
   begin
	
	  set @res = @res + cast(cast(@shStart as time) as datetime)
	
   end  
   else 
   begin
	
	if @ptype is null and @vtype=10 
		set @ptype = 1 --в случае многодневного отпуска ставится NULL, нужно менять на полный день KB2879
   
     if @ptype = 1 /*full*/
     begin
        set @res = dateadd(hour,3,@res)
     end     
     else if @ptype = 2 /*forenoon*/   
     begin    
        set @res = dateadd(hour,3,@res)      
     end
     if @ptype = 3 /*afternoon*/
     begin
       set @res = dbo.COM_TURN_MIDDLE(@EmplID,@res)
     end
   
   end 
   
   return @res
  
end