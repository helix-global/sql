CREATE PROCEDURE [dbo].[PM_TASK_2DEP_NOTIFICATION] @UserID int, @aMode int
AS
BEGIN
  set nocount on

  declare @now datetime
  set @now = GETDATE()

  declare @TaskID int
  declare @TaskSubj nvarchar(500)
  declare @ProjectName nvarchar(500)
  declare @msg nvarchar(max)
  declare @pdbLink nvarchar(250)
  declare @RespDepCode nvarchar(50)
  declare @RespDepID int
  declare @OwnDepCode nvarchar(50)
  declare @FromJira nvarchar(10) /* KB4239 from comments */
  
  
  declare @now5 datetime
  set @now5 = dateadd(minute,-5,@now)

  select top 1 @TaskID = A.ID
      ,@TaskSubj = A.SUBJ
      ,@ProjectName = D.NAME
      ,@RespDepID = A.RESPDEP
      ,@RespDepCode = H.CODE
      ,@OwnDepCode = J.CODE
	  ,@FromJira = case when isnull(D.JIRA_ID,0) = 0 then 'No' else 'Yes' end /* KB4239 from comments */

    from PM_TASK A with (nolock)
    left join PM_PROJECT D with (nolock) on D.ID = A.PROJID
    left join COM_DEPARTMENTS H with (nolock) on H.ID = A.RESPDEP
    left join COM_DEPARTMENTS J with (nolock) on J.ID = A.DEPID
   where A.RESPDEP_NOTIFIED is null
     and isnull(A.S_MDT,A.S_CDT) < @now5
     and A.DEPID <> A.RESPDEP
     and A.S_S = 1
   order by A.ID 
   
   
   
  if @TaskID is not null 
  begin
	  set @pdbLink = '<a href="a2l:\\Link=doc.pm_task.'+ltrim(str(@TaskID))+'">(Open task in PDB)</a>'
	  
	  set @msg = N'Dear All,<br><br>The following task has been created for '+@RespDepCode+' department:<br><br>'
	  set @msg = @msg + N'<b>'+@TaskSubj+'</b><br>'+@pdbLink+'<br><br>'
	  set @msg = @msg + N'From Jira: '+ @FromJira +'<br>'	/* KB4239 from comments */
	  set @msg = @msg + N'Owner department: '+@OwnDepCode+'<br>'
	  set @msg = @msg + N'Project: '+@ProjectName+'<br>'
	  set @msg = @msg + N'<br><br>Please, do not answer this e-mail.<br>Production Database'

	    
	  exec MSG_SEND_TODEP_HEADS @UserID, @RespDepID, null, 0, 'New Task for Department Notification', @msg
	  /*exec MSG_SEND @userID, 'dnorkin@ipgphotonics.com', null,'New Task for Department Notification', @msg*/

	  update PM_TASK set RESPDEP_NOTIFIED = @now, RESPDEP_NOTIFIED_ID = RESPDEP  where ID = @TaskID

	  print 'work done'

  end

  set nocount off

END