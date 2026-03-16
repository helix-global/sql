CREATE function [dbo].[COM_VACATION_DBEG](@aID int)
returns datetime as 
begin
  
  declare @res datetime 
  
  declare @dbeg datetime
  declare @dend datetime
  declare @vtype int
  declare @ptype int
  declare @shDuration int
  declare @shStart datetime
  declare @specialShort int
   
   select @dbeg = A.DBEG
        , @dend = A.DEND
        , @vtype = A.VACATIONTYPE
        , @ptype = A.PERIODTYPE
        , @shStart = A.SHORTSTART
        , @shDuration = A.SHORTDURATION
        , @specialShort = ISNULL(A.P_SPLEAVE_SHORT,0)
   from COM_VACATION A with (nolock)
   where A.ID = @aID
   
   set @res = cast(@dbeg as date)
   
   if @vtype in (30,80,200) /*short absence, int.appoint*/
   begin
   
      set @res = @res + cast(cast(@shStart as time) as datetime)
   
   end
   else if @vtype = 70 and @specialShort = 1
   begin
	
	  set @res = @res + cast(cast(@shStart as time) as datetime)
	
   end
   else 
   begin
   
     if @ptype = 3 /*afternoon*/
       set @res = dateadd(hour,12,@res)
   
   end 
   
   return @res
  
end