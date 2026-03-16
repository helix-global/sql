CREATE function [dbo].[IMS_PLAN_TRAINING_DATE_VALID](@aEmplID int, @aPlanID int, @aComplDate date, @aNow date)
returns int as 
begin

/*
возвращает 1 если от момента @aComplDate до @aNow прошло не больше времени, чем указано в плане
т.е. @aComplDate еще считается валидным и на дату @aNow еще не надо переучиваться
*/

   if @aComplDate is null
     return null

   declare @period int
   declare @pvalue int

   select @period = A.SNOOZEPERIOD
	   ,@pvalue = A.SNOOZEPERIODVALUE
   from IMS_TRAINING_PLAN A
   where A.ID = @aPlanID

   if @period = 10000
      return 1  /*валидно бессрочно*/ 

   declare @temp date
   
   if @period = 10 
     set @temp = dateadd(day,@pvalue,@aComplDate)
   else if @period = 20 
     set @temp = dateadd(week,@pvalue,@aComplDate)
   else if @period = 30 
     set @temp = dateadd(month,@pvalue,@aComplDate)
   else if @period = 40 
     set @temp = dateadd(year,@pvalue,@aComplDate)
   
   if @temp > @aNow
     return 1
   
   return 0 

end