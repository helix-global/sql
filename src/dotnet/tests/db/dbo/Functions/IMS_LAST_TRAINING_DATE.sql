create function [dbo].[IMS_LAST_TRAINING_DATE](@aEmplID int, @aPlanID int)
returns date as 
begin

   declare @res date
   
   select top 1 @res = GG.COMPLETED_D 
   from IMS_TRAINING GG with (nolock) 
   where GG.EMPLID = @aEmplID 
     and GG.TRAININGPLANID = @aPlanID
     and GG.COMPLETED_D is not null
   order by GG.COMPLETED_D desc
   
   return @res 

end