CREATE function [dbo].[COM_VACATION_LEN](@aID int,@aMode  int)
returns decimal(16,1) as 
begin
   
  declare @res decimal(16,1)
  
  declare @dbeg datetime
  declare @dend datetime
  declare @vtype int
  declare @ptype int
  declare @shDuration int
  declare @emplID int
   
   select @dbeg = A.DBEG
        , @dend = A.DEND
        , @vtype = A.VACATIONTYPE
        , @ptype = A.PERIODTYPE
        , @shDuration = A.SHORTDURATION
        , @emplID = A.EMPLID
   from COM_VACATION A with (nolock)
   where A.ID = @aID
   
   
   if @vtype not in (30,80,200)
   begin
   
     if isnull(@ptype,1) = 1 /*full*/
     begin
     
       declare @wtID int 
       declare @CalendarID int
       
       select @wtID = ISNULL(A.PERSONALWT,B.ID)
             ,@CalendarID = coalesce(B2.CALENDAR,B.CALENDAR,1)
	   from COM_EMPLOYEE A with (nolock) 
	   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
	   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
	   where A.ID = @emplID;
     
       set @res = dbo.COM_WORK_DAYS2(@dbeg,isnull(@dend,@dbeg),@CalendarID,@wtID)
       
     end
     else  
       set @res = 0.5
   
   end
   
   return @res
  
end