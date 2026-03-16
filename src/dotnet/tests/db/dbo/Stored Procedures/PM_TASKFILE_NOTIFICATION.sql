create PROCEDURE [dbo].[PM_TASKFILE_NOTIFICATION] @UserID int, @UpdateKind int, @TaskID int, @FileName nvarchar(250), @aMode int
AS
BEGIN
  set nocount on

  declare @pdbLink nvarchar(max)
  declare @msg nvarchar(max)
  declare @toAddr nvarchar(1024)
  declare @TaskSubj nvarchar(500)
  
  select @toAddr = isnull(@toAddr,'')+B.EMAIL+'; '
  from PM_TASK_ASSIGNEE A with(nolock)
  left join COM_EMPLOYEE B with(nolock) on B.ID = A.EMPLID
  where A.VNESHID = @TaskID
    and B.EMAIL is not null
    
  if @UpdateKind not in (1,0) or @toAddr is null or len(ltrim(rtrim(@toAddr))) < 5
  begin
	set nocount off
    return
  end  
  
  select @TaskSubj = isnull(A.SUBJ,'NA')
  from PM_TASK A with(nolock)
  where A.ID = @TaskID
  

  set @pdbLink = '<a href="a2l:\\Link=doc.pm_task.'+ltrim(str(@TaskID))+'">(Open task in PDB)</a><br>'
	  
  if @UpdateKind = 1	  
	set @msg = 'Dear all,<br><br>The following file has been added to task:<br><br>'
  else
	set @msg = 'Dear all,<br><br>The following file has been deleted from task:<br><br>'  	
	
  set @msg = @msg + '<b>'+@TaskSubj+'</b><br>'+@pdbLink+'<br><br>'
  set @msg = @msg + 'File name: '+@FileName+'<br>'
  set @msg = @msg + '<br><br>Please, do not answer this e-mail.<br>Production Database'
	    
  exec MSG_SEND @UserID, @toAddr, null,'Task File Change Notification', @msg
  /*
  set @msg = @msg+'<br>---<br>'+@toAddr
  exec MSG_SEND @UserID, 'dnorkin@ipgphotonics.com', null,'Task File Change Notification', @msg
  */

  set nocount off

END