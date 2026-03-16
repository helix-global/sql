create FUNCTION [dbo].[PM_TASK_LABOREST](@TaskID int, @mode int)
RETURNS decimal(10,2)
AS
BEGIN
  declare @res decimal(10,2) = 0
  /*
  KB3554 п.5 цитата:
  Если у задачи есть дочерние задачи и в списке Assigned у нее нет сотрудника, то поле Labor Estimate должно 
  быть нередактируемым для пользователей, и автоматически рассчитываться как сумма Labor Estimate по всем дочерним задачам.  
  
  Эта функция считает сумму по дочерним при наличии дочерних и отсутствии assigned
  
  ??? нужно ли делать это рекурсивно ??? разница м.б. из-за того, что вбитое в поле LABOR_EST не соответствует сумме дочерних
  
  */
  if exists(select R.ID from PM_TASK R with(nolock) where R.PARENTID = @TaskID) 
     and not exists(select P.ID from PM_TASK_ASSIGNEE P with(nolock) where P.VNESHID = @TaskID)
  begin   
   
    select @res = sum(A.LABOR_EST)
	from PM_TASK A with(nolock)
	where A.ID in (select ID from dbo.PM_GET_CHILD_TASKS(@TaskID,0))
  
  end
  else
  begin
  
	select @res = A.LABOR_EST
	from PM_TASK A with(nolock)
	where A.ID = @TaskID    
  
  end
  
  return @res

END