create function [dbo].[PR_ELAPSED3](@aTimeID int,@dEnd datetime,@Elapsed_D decimal(12,2),@ElapsedOld int)
returns decimal(12,2) as 
begin
  
  
   if @dEnd is null
     return dbo.PR_WORKTIME3(@aTimeID,getdate())
   
   if @Elapsed_D is null
      return @ElapsedOld
        
   return @Elapsed_D   
     

end