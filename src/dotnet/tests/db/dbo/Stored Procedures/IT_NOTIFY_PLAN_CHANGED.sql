
CREATE PROCEDURE [dbo].[IT_NOTIFY_PLAN_CHANGED]
	(
		@taskID int, @PLAN_WEEK_OLD int, @PLAN_WEEK_NEW int, @UserID int
	)
AS
BEGIN

	--set @PLAN_WEEK_OLD=ISNULL(@PLAN_WEEK_OLD,0)
	--set @PLAN_WEEK_NEW=ISNULL(@PLAN_WEEK_NEW,0)
	declare @curEmpId int
	set @curEmpId=dbo.DEF_EMPLOYEE(@UserID)

	declare @toUserId int, @tEmpId int, @tickNum nvarchar(10), @tSubj nvarchar(512), @toEmpId int, @modUserName nvarchar(200)

	select @toUserId = T.S_CR, @tEmpId=dbo.DEF_EMPLOYEE(T.S_CR), @tickNum=T.TICKETN, @tSubj=T.SUBJ, @modUserName=dbo.DEF_USER(isnull(T.S_MR,@UserID),1)
		from IT_TASKS T
		where T.ID=@taskID 
	
	declare @t table (EMPID int)

	insert into @t (EMPID)
	select N.EMPID
		from IT_KB_NOTIFICATIONS N
		where (isnull(N.ONLYMY,0)=0 or (isnull(N.ONLYMY,0)=1 and N.EMPID=@tEmpId))
			and isnull(N.PLAN_CHANGE,0)=1
			and N.EMPID<>@curEmpId
		
	declare @subj nvarchar(1024), @body nvarchar(max)

	set @subj = 'KB' + CAST(@taskID as nvarchar(10)) + ': ' +
				'Planned week changed'

	set @body = 'Dear all,<br><br>' +
				'<b>KB Task <a href = "a2l:\\Link=doc.it_task.'+LTRIM(rtrim(str(@taskID)))+'">' + CAST(@taskID as nvarchar(10)) + '</a></b>: planned week was changed by ' + @modUserName + '.<br><br>' +
				'<b>Subject</b>: ' + isnull(@tSubj,'Not set') + '<br><br>' +
				'<b>Old value</b>: ' + isnull(cast(@PLAN_WEEK_OLD as nvarchar(20)),'Not set') + ', <b>New value</b>: ' + isnull(cast(@PLAN_WEEK_NEW as nvarchar(20)),'Not set') + '<br><br>' +
				'<b>Ticket Number</b>: ' + ISNULL(' <a href="http://ipgl-bu-support.ipgphotonics.com/WorkOrder.do?woMode=viewWO&woID=' + @tickNum + '&fromListView=true">' + @tickNum + '</a>','Not set')

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