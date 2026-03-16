CREATE function [dbo].[COM_IS_WORKTIME](@aDT datetime, @aEmplID int)
returns int as 
begin
   
   if dbo.COM_IS_VACATION_TIME(@aDT, @aEmplID) = 1
      return -2
   
   if exists  (select A.ID from COM_ADDED_WORKTIME A with (nolock) where A.EMPLID = @aEmplID and @aDT between A.DBEG and A.DEND)
      return 1
     
   declare @wtID int
   declare @Calendar int
   
   select @wtID = ISNULL(A.PERSONALWT,B.ID), @Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @aEmplID
   
   if @wtID is null
     return 1 /* если график не указан все время считать рабочим*/
     
   /*KB3228*/  
   declare @ddd date = cast(@aDT as date)
   declare @searchFrom date = dateadd(day,-2,@ddd)
   declare @searchTo date = dateadd(day,2,@ddd)
   
   if exists (select * 
                from dbo.COM_WORKPERIODS3(@searchFrom,@searchTo,@Calendar,@wtID,@aEmplID) GG 
               where GG.DBEG <= @aDT and @aDT <= GG.DEND
              )
              return 1
   
   /*     
   declare @at time
   declare @ad date
   declare @ad_corrected date
   set @at = cast(@aDT as time)  
   set @ad = cast(@aDT as date)  
   set @ad_corrected = @ad
   if datepart(hour,@aDT) < 3
     set @ad_corrected = dateadd(day,-1,@ad_corrected)
  
   declare @wturn int
   select @wturn = A.WTURN from COM_TURNS A with (nolock) where A.EMPLID = @aEmplID and A.DD = @ad_corrected
   set @wturn = ISNULL(@wturn,1)
   
   if @wturn = 1 and dbo.COM_IS_WORKDAY2(@aDT,@Calendar,@wtID) = 0
     return 0

   if @wturn > 1 and dbo.COM_IS_WORKDAY2(dateadd(hour,-3,@aDT),@Calendar,@wtID) = 0
     return 0
   
     
   if exists  (select A.ID from COM_WORKTIME_BR A with (nolock) 
                where A.VNESHID = @wtID 
                  and A.WTURN = @wturn 
                  and @at between cast(A.TFROM as time) and cast(A.TTO as time))
      return 1
   
   if @wturn > 1 and exists  (select A.ID from COM_WORKTIME_BR A with (nolock) 
                where A.VNESHID = @wtID 
                  and A.WTURN = @wturn 
                  and cast(A.TFROM as time) > cast(A.TTO as time)
                  and dbo.COM_IS_WORK_NIGHT(@aDT,cast(A.TFROM as time),cast(A.TTO as time)) = 1) 
      return 1
   */
   
   
   return -1

end