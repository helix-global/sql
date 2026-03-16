CREATE function [dbo].[IMS_TRAININGPLAN_FILELINK](@aEmplID int, @aTrainingPlanID int, @aReportDate date, @aMode int)
returns int as 
begin

  declare @res int
  
  /*последний файл, прикрепленный к завершенному тренингу с максимальной датой завершения, но не больше @aReportDate */ 
              
  select top 1 @res = G.ID
  from IMS_TRAINING A with (nolock) 
  left join IMS_TRAINING_FILES G with (nolock) on G.VNESHID = A.ID
  where A.EMPLID = @aEmplID 
    and A.TRAININGPLANID = @aTrainingPlanID
    and A.S_S = 2130037/*certified*/
    and A.COMPLETED_D <= @aReportDate    
  order by A.COMPLETED_D desc, G.ID desc
   
  return @res 

end