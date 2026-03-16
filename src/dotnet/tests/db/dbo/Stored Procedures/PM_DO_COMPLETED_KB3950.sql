CREATE PROCEDURE [dbo].[PM_DO_COMPLETED_KB3950] @UserID int, @aMode int
AS
BEGIN
  /*KB3950 п.3
  если все подзадачи задачи получают статус Approved и у самой задачи нет исполнителя,
   то задача автоматически переводится в статус Completed 
  
  >>с соотв. информированием автора задачи.
  рассылка по идее должна отработать из PM_COMPLETED_KB3824 
  т.к. она как раз подбирает задачи в статусе Completed

  + KB4186 п.1  ... и не стоит галочка «Exclude from Planing»

  */
  set nocount on

  declare @task2process int
  
  select top 1 @task2process = A.ID
	from PM_TASK A with(nolock)
	where A.S_S = 1 /*?*/
	  and not exists (select B.ID from PM_TASK_ASSIGNEE B with(nolock) where B.VNESHID = A.ID)
	  and exists (select G.ID from PM_TASK G with(nolock) where G.PARENTID = A.ID)
	  and not exists (select FF.ID
						from PM_TASK FF with(nolock) 
						where FF.ID in (select ID from dbo.PM_GET_CHILD_TASKS(A.ID,0))
						  and FF.S_S <> 2130067  /*approved*/
					  )      
	  and isnull(A.EXCLFROMPLAN,0) = 0 /* + KB4186 п.1  ... и не стоит галочка «Exclude from Planing» */

  if @task2process is null
  begin
	  set nocount off 
	  return  
  end					  

  
  update PM_TASK set S_S = 2130066 /*completed*/ where PM_TASK.ID = @task2process and PM_TASK.S_S = 1

  
  set nocount off 

END