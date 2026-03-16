CREATE PROCEDURE [dbo].[PM_TASK_NOTIFICATION] @UserID int, @aMode int
AS
BEGIN
  set nocount on

  declare @now datetime
  set @now = GETDATE()

  declare @ID int
  declare @TaskID int
  declare @EmplID int
  declare @TaskSubj nvarchar(500)
  declare @ParentTaskSubj nvarchar(500)
  declare @ProjectName nvarchar(500)
  declare @EmplName nvarchar(250)
  declare @msg nvarchar(max)
  declare @pdbLink nvarchar(250)
  
  declare @now5 datetime
  set @now5 = dateadd(minute,-5,@now)

  select top 1 @ID = A.ID
      ,@TaskID = B.ID
      ,@EmplID = A.EMPLID 
      ,@EmplName = coalesce(C.GIVENNAME,C.NAME)
      ,@TaskSubj = B.SUBJ
      ,@ProjectName = D.NAME
      ,@ParentTaskSubj = BB.SUBJ
    from PM_TASK_ASSIGNEE A with (nolock) 
    left join PM_TASK B with (nolock)  on B.ID = A.VNESHID
    left join COM_EMPLOYEE C with (nolock) on C.ID = A.EMPLID
    left join PM_PROJECT D with (nolock) on D.ID = B.PROJID
    left join PM_TASK as BB with (nolock) on BB.ID = B.PARENTID
   where A.EMPL_NOTIFIED is null
     and isnull(A.S_MDT,A.S_CDT) < @now5
   order by B.ID desc
   
  if @ID is not null 
  begin
	  set @pdbLink = '<a href="a2l:\\Link=doc.pm_task.'+ltrim(str(@TaskID))+'">(Open task in PDB)</a><br>'
	  
	  declare @taskuserID int
	  select top 1 @taskuserID = A.ID from DEF_USERS A with (nolock) where A.EMPLOYEEID = @EmplID
	  if dbo.DEF_CLASS_ACCESS(2130060,'pm_task',2,@now,@taskuserID) <> 1
	     set @pdbLink = '';
	  
	  set @msg = N'Dear '+@EmplName+',<br><br>The following task has been assigned to you:<br><br>'
	  set @msg = @msg + N'<b>'+@TaskSubj+'</b><br>'+@pdbLink+'<br>'
	  set @msg = @msg + N'Project: '+@ProjectName+'<br>'
	  if @ParentTaskSubj is not null
	     set @msg = @msg + 'Parent task: '+@ParentTaskSubj+'<br>'
	  set @msg = @msg + '<br><br>Please, do not answer this e-mail.<br>Production Database'
	    
	  exec MSG_SEND_TOEMPLOYEE @UserID, @EmplID, 'New Task Assignment Notification', @msg
	  /*exec MSG_SEND @userID, 'dnorkin@ipgphotonics.com', null,'New Task Assignment Notification', @msg*/

	  update PM_TASK_ASSIGNEE set EMPL_NOTIFIED = @now, EMPL_NOTIFIED_ID = EMPLID  where ID = @ID

	  print 'work done'

  end

  set nocount off

END