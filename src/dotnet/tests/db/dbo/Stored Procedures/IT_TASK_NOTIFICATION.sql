CREATE PROCEDURE [dbo].[IT_TASK_NOTIFICATION] @UserID int, @aMode int
AS
BEGIN
  set nocount on

  declare @taskID int
  
  select top 1 @taskID = A.ID 
  from IT_TASKS A with (nolock) 
  where A.PRIORITY = 1
    and A.DEV_NOTIFICATION is null
    and A.S_CDT > '20210427'
    and A.S_S = 1
    and dateadd(second,20,A.S_CDT) < getdate()
    
  if @taskID is not null
  begin
  
    declare @subj nvarchar(1024)
    declare @mess nvarchar(max)
    
    select @subj = 'New kanban task with "High" priority was created: '+isnull(A.SUBJ,'')
		  ,@mess = '<a href = "a2l:\\Link=doc.pm_task_time.'+cast(A.ID as nvarchar(14))+'">'+isnull(A.SUBJ,'')+'</a><br><br>'+isnull(cast(A.BODY as nvarchar(max)),'')
    from IT_TASKS A with (nolock) 
    where A.ID = @taskID
    
    exec MSG_SEND_TODELIVERYGROUP @UserID,8888,278,@subj,@mess
    
    update IT_TASKS set DEV_NOTIFICATION = getdate() where ID = @taskID
  
  end  
  
  set nocount off
END