CREATE function [dbo].[COM_WORKING_DAYS_COUNT](@dBeg datetime,@dEnd datetime,@aEmplID int)
returns int as 
begin
   
   /* в отличие от COM_WORK_DAYS вычитает дни в которых полный день - отпуск */
   
   declare @res int
   declare @CalendarID int 
   
   declare @wtID int

   select @wtID = ISNULL(A.PERSONALWT,B.ID)
        , @CalendarID = ISNULL(B2.CALENDAR,B.CALENDAR)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @aEmplID;
   
   select @res = count(*) 
   from dbo.COM_DAY_PERIOD(@dBeg,@dEnd) A
   where dbo.COM_IS_WORKDAY2(A.DDATE, @CalendarID, @wtID) = 1
     and dbo.COM_IS_VACATIONDAY(A.DDATE,@aEmplID) <> 1
     
   return @res 

end