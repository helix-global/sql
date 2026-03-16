CREATE function [dbo].[COM_ATTENDANCE_TIME3](@aUserID int,@aEmplID int,@aDay datetime)
returns decimal(16,3) as 
begin

/* v.3 считает также ночную часть смены ПРЕДЫДУЩЕГО рабочего дня (текущего КАЛЕНДАРНОГО дня)
  сделана для KB3559 для расшифровки LUR где Available выводится по КАЛЕНДАРНЫМ дням 
  и получается что в день попадает только часть ночной смены, которая до полночи
  но человек работал в этот же календарный день рано утром от смены предыдущего дня 
  - это COM_WORK_MINUTS6 в стандарте не берет 
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
   
   select @res = dbo.COM_WORK_MINUTS6 (@dd, dateadd(day,1,@dd), @wtID, @Calendar, @emplID) where dbo.COM_IS_WORKDAY2(@dd,@Calendar,@wtID) = 1

   /*добавка того, о чем написан комментарий */   
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