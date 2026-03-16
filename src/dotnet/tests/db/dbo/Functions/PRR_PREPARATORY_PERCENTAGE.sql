CREATE function [dbo].[PRR_PREPARATORY_PERCENTAGE] (@ConstInOperations decimal(12,1), @AllPreparatory decimal(12,1))
returns decimal(12,1) 
as 
begin
/* непонятно как показать сколько всего @AllPreparatory если в @ConstInOperations ноль*/


   if @ConstInOperations = @AllPreparatory and @AllPreparatory <> 0
      return 100
   
   if @AllPreparatory > 0
      return @ConstInOperations / @AllPreparatory * 100 

                      
   return null
    
end