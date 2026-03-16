CREATE function [dbo].[COM_ATTENDANCE_TIME5](@aUserID int,@aEmplID int,@aDay datetime, @mode int, @DepID int)
returns decimal(16,3) as 
begin

/* 
  сделана на основе COM_ATTENDANCE_TIME4
  для KB4814 использует dbo.COM_WORK_MINUTS6_MODE , которая при @mode=22 добавляет "possible" смены по периодам KurzArbeit

*/

   declare @emplID int
   if @aEmplID is not null
     set @emplID = @aEmplID
   else
     select @emplID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID

   declare @dd datetime
   set @dd = CAST(@aDay as date)

   declare @wtID int
   declare @Calendar int

   select @wtId = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@emplID,@dd)
   select @Calendar = A.CALENDAR from COM_WORKTIME A with (nolock) where A.ID = @wtId     
  
   if @wtID is null
     return null

   declare @res decimal(16,3) 
   
   select @res = dbo.COM_WORK_MINUTS6_MODE (@dd, dateadd(day,1,@dd), @wtID, @Calendar, @emplID, @mode, @DepID) 
   where dbo.COM_IS_WORKDAY2(@dd,@Calendar,@wtID) = 1
     or exists (select H.ID from COM_ADDED_WORKTIME H with(nolock) 
                 where H.EMPLID = @emplID
                   and cast(H.DEND as date) >= @dd
                   and cast(H.DBEG as date) <= @dd)

   /*добавка того, о чем написан комментарий в v3 */   
   declare @addRes decimal(16,3)
   
   select @addRes = sum(dbo.COM_DURATION_NOTVACATION_SECONDS(@emplID,@wtId,DBEG,DEND))/60
   from ( 
	select case when DBEG < @dd then @dd else DBEG end as DBEG 
		  ,DEND
	from dbo.COM_TURNS_AROUND(@dd,@wtId,@emplID) 
	where (ACTIVATEDWTURN = 1 or ONLYONEWTURN = 1) 
	  and WORKDAY = dateadd(day,-1,@dd)
	  and cast(DEND as date) = @dd
   )M  
   

   set @res = @res + isnull(@addRes,0)   


   return @res

end