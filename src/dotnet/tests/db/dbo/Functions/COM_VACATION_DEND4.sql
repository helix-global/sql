CREATE function [dbo].[COM_VACATION_DEND4](@aID int)
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
   
     if @ptype in (1,3) /*full,afternoon*/
     begin
          declare @defres datetime 
          set @defres = cast(isnull(@dend,@dbeg) as date) 
          set @res = @defres
          declare @wt int = dbo.COM_WORKTABLE_BY_DATE(@res,@EmplID)
          select @res=max(DEND) from dbo.COM_WORKPERIODS5(@res,@res+1,1,@wt,@EmplID)
          
          set @res = isnull(@res,dateadd(day,1,@defres))

     end     
     else if @ptype = 2 /*forenoon*/       
     begin
        set @res = cast(@dbeg as date)   
        set @res = dbo.COM_TURN_MIDDLE(@EmplID,@res)
     end     
     
   end 
   
   return @res
  
end