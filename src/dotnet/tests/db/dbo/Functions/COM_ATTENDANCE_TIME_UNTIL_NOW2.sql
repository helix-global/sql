create function [dbo].[COM_ATTENDANCE_TIME_UNTIL_NOW2](@aUserID int,@aEmplID int,@aDay datetime,@Now datetime)
returns int as 
begin

   /* v.2 переведена на общую функцию COM_WORK_MINUTS6, которая учитывает отпуск */

   declare @emplID int
   if @aEmplID is not null
     set @emplID = @aEmplID
   else
     select @emplID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID

   declare @dd datetime
   set @dd = CAST(@aDay as date)

   declare @Calendar int
   declare @wtID int

   select @wtID = ISNULL(A.PERSONALWT,B.ID), @Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @emplID;

   if @wtID is null
     return null
     
   declare @dend datetime = dateadd(day,1,@dd)
   if @dend > @Now
      set @dend = @Now

   return dbo.COM_WORK_MINUTS6 (@dd, @dend, @wtID, @Calendar, @emplID)

end