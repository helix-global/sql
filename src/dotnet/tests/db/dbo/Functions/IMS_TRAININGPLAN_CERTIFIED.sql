CREATE function [dbo].[IMS_TRAININGPLAN_CERTIFIED](@aEmplID int, @aTrainingPlanID int, @aReportDate date, @aMode int)
returns date as 
begin

   declare @res date
   
   if exists (select A.ID from IMS_TRAINING A with (nolock) 
               where A.EMPLID = @aEmplID 
                 and A.TRAININGPLANID = @aTrainingPlanID
                 and A.S_S = 2130037/*certified*/
                 and A.COMPLETED_D <= @aReportDate 
                 and dbo.IMS_PLAN_TRAINING_DATE_VALID(A.EMPLID, A.TRAININGPLANID, A.COMPLETED_D, @aReportDate) = 1
              )
              begin
                 set @res = '40001212'
                 return @res
              end
              
   select top 1 @res = B.DD
   from IMS_TRAINING A with (nolock) 
   left join IMS_TRAINING_SCHEDULE_DATES B with (nolock) on B.ID = A.SCHEDULEDATEID 
   where A.EMPLID = @aEmplID 
     and A.TRAININGPLANID = @aTrainingPlanID
     and A.S_S in (2130032/*planned*/,2130033/*inprogress*/,2130034/*completed*/)
     and B.DD is not null
   order by B.DD
   
   
   if @res is null  /*обучение не запланировано*/
   begin
   
      /* обучение было, но просрочено (функция ..VALID вернула 0) */
      if exists (select A.ID from IMS_TRAINING A with (nolock) 
               where A.EMPLID = @aEmplID 
                 and A.TRAININGPLANID = @aTrainingPlanID
                 and A.S_S = 2130037/*certified*/
                 and A.COMPLETED_D <= @aReportDate 
                 and dbo.IMS_PLAN_TRAINING_DATE_VALID(A.EMPLID, A.TRAININGPLANID, A.COMPLETED_D, @aReportDate) = 0
              )
              begin
                 set @res = '19901212'  /* по этой метке в отчете будет прочерк */
                 return @res
              end
   
   end   
   
   return @res 

end