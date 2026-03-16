CREATE function [dbo].[IMS_TRAINING_CERTIFIED](@aEmplID int, @aTrainingTypeID int, @aReportDate date, @aMode int)
returns date as 
begin



   declare @res date
   
   if exists (select A.ID from IMS_TRAINING A with (nolock) 
               where A.EMPLID = @aEmplID 
                 and A.TRAININGTYPEID = @aTrainingTypeID
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
     and A.TRAININGTYPEID = @aTrainingTypeID
     and A.S_S in (2130032/*planned*/,2130033/*inprogress*/,2130034/*completed*/)
     and B.DD is not null
   order by B.DD
   
  
   
   return @res 

end