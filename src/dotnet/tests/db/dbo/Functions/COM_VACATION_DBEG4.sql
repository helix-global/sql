CREATE function [dbo].[COM_VACATION_DBEG4](@aID int)
returns datetime as 
begin
  /* версия 4 выдает время с учетом смены и графика */
  
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
        , @ptype = isnull(A.PERIODTYPE,1)
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
   
     if @ptype in (1,2) /*full,forenoon*/
     begin
        
          declare @wt int = dbo.COM_WORKTABLE_BY_DATE(@res,@EmplID)
          select @res = min(DBEG) from dbo.COM_WORKPERIODS5(@res,@res+1,1,@wt,@EmplID)
          
          set @res = isnull(@res,@dbeg)
             
     end
     if @ptype = 3 /*afternoon*/
     begin
     
       set @res = dbo.COM_TURN_MIDDLE(@EmplID,@res)
       
     end
   
   end 
   
   return @res
  
end