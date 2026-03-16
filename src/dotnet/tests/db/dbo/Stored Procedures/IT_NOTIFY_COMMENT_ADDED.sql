
CREATE PROCEDURE [dbo].[IT_NOTIFY_COMMENT_ADDED]
	(
		@commID int, @UserID int
	)
AS
BEGIN
	declare @curEmpId int
	set @curEmpId=dbo.DEF_EMPLOYEE(@UserID)

	declare @commText nvarchar(max)
	declare @taskId int, @cEmpId int
	declare @tEmpId int, @tickNum nvarchar(10), @tSubj nvarchar(512), @toEmpId int, @assignId int, @crUserName nvarchar(200)

	select @taskId = C.TASKID, @commText=C.CTEXT, @cEmpId=dbo.DEF_EMPLOYEE(C.S_CR), @crUserName=dbo.DEF_USER(C.S_CR,1)
		from IT_TASK_COMMENTS C
			where C.ID=@commID

	select @tEmpId=dbo.DEF_EMPLOYEE(T.S_CR), @tickNum=T.TICKETN, @tSubj=T.SUBJ, @assignId=dbo.DEF_EMPLOYEE(T.ASSIGNEE)
		from IT_TASKS T
		where T.ID=@taskID 
	
	declare @t table (EMPID int)
		
	insert into @t (EMPID)
	select N.EMPID
		from IT_KB_NOTIFICATIONS N
		where (isnull(N.ONLYMY,0)=0 or (isnull(N.ONLYMY,0)=1 and N.EMPID in(@tEmpId,@assignId)))
			and isnull(N.COMMENT_ADD,0)=1
			and N.EMPID<>@cEmpId
			and N.EMPID<>@curEmpId

	declare @subj nvarchar(1024), @body nvarchar(max)

	set @subj = 'KB' + CAST(@taskID as nvarchar(10)) + ': ' +
			'New comment added'
	set @body = 'Dear all,<br><br>' +
				'<b>KB Task <a href = "a2l:\\Link=doc.it_task.'+LTRIM(rtrim(str(@taskID)))+'">' + CAST(@taskID as nvarchar(10)) + '</a></b>: new comment added by ' + @crUserName + '.<br><br>' +
				'<b>Subject</b>: ' + isnull(@tSubj,'Not set') + '<br><br>' +
				'<b>Ticket Number</b>: ' + ISNULL(' <a href="http://ipgl-bu-support.ipgphotonics.com/WorkOrder.do?woMode=viewWO&woID=' + @tickNum + '&fromListView=true">' + @tickNum + '</a>','Not set') + '<br><br>' +
				'<b>Content</b>: <br><br>' + @commText

	DECLARE cur_it_kb_notification CURSOR FOR
	SELECT EMPID from @t
					
	OPEN cur_it_kb_notification

	FETCH NEXT FROM cur_it_kb_notification INTO @toEmpId

	WHILE @@FETCH_STATUS=0
	BEGIN
	
		exec MSG_SEND_TOEMPLOYEE @UserID, @toEmpId, @subj, @body
	
		FETCH NEXT FROM cur_it_kb_notification INTO @toEmpId
	END

	CLOSE cur_it_kb_notification
	DEALLOCATE cur_it_kb_notification
END