create function [dbo].[IMS_NEXT_TRAINING_DATE2](@aEmplID int, @aPlanID int)
returns date as 
begin

/*v2 возвращает 12.12.4000 когда период 10000 "Valid Indefinitely" и ЕСТЬ дата завершенного обучения  */

   declare @period int
   declare @pvalue int

   select @period = A.SNOOZEPERIOD
	   ,@pvalue = A.SNOOZEPERIODVALUE
   from IMS_TRAINING_PLAN A
   where A.ID = @aPlanID

   declare @res date
   
   select top 1 @res = GG.COMPLETED_D 
   from IMS_TRAINING GG with (nolock) 
   where GG.EMPLID = @aEmplID 
     and GG.TRAININGPLANID = @aPlanID
     and GG.COMPLETED_D is not null
   order by GG.COMPLETED_D desc
   
   
   if @res is not null
   begin
     
     if @period = 10 
       set @res = dateadd(day,@pvalue,@res)
     else if @period = 20 
       set @res = dateadd(week,@pvalue,@res)
     else if @period = 30 
       set @res = dateadd(month,@pvalue,@res)
     else if @period = 40 
       set @res = dateadd(year,@pvalue,@res)
     else if @period = 10000
       set @res = '40001212'
   
   end
   
   return @res 

end