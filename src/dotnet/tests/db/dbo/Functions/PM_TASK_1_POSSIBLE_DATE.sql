create FUNCTION [dbo].[PM_TASK_1_POSSIBLE_DATE](@TaskID int, @mode int)
RETURNS datetime
AS
BEGIN

   /*возвращает максимальную дату isnull(PlannedDate,DueDate) с задач, которые predecessors для текущей задачи*/  
   
   declare @res datetime
   
   select @res = max(isnull(B.PLANDATE,B.DUEDATE)) 
   from PM_TASK_DEPEND A with (nolock)
   left join PM_TASK B with (nolock) on B.ID = A.VNESHID
   where A.TOTASKID = @TaskID
   
   return @res


END