CREATE function [dbo].[COM_VACATION_DEND](@aID int)
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
   
   select @dbeg = cast(A.DBEG as date)
        , @dend = cast(A.DEND as date)
        , @vtype = A.VACATIONTYPE
        , @ptype = isnull(A.PERIODTYPE,1)
        , @shStart = A.SHORTSTART
        , @shDuration = A.SHORTDURATION
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
     end     
     else if @ptype = 2 /*forenoon*/       
     begin
        set @res = @dbeg
        set @res = dateadd(hour,12,@res)
     end     
     else if @ptype = 3 /*afternoon*/
     begin
        set @res = @dbeg
        set @res = dateadd(hour,24,@res)
     end
     
   end 
   
   return @res
  
end