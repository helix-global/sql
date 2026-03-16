
CREATE PROCEDURE [dbo].[IT_NOTIFY_STATE_CHANGED]
	(
		@taskID int, @S_S_OLD int, @S_S_NEW int, @UserID int
	)
AS
BEGIN
	declare @curEmpId int
	set @curEmpId=dbo.DEF_EMPLOYEE(@UserID)

	declare @toUserId int, @tEmpId int, @tickNum nvarchar(10), @tSubj nvarchar(512), @toEmpId int, @modUserName nvarchar(200), @crUserName nvarchar(200)

	select @toUserId = T.S_CR, @tEmpId=dbo.DEF_EMPLOYEE(T.S_CR), @tickNum=T.TICKETN, @tSubj=T.SUBJ, @modUserName=dbo.DEF_USER(T.S_MR,1), @crUserName=dbo.DEF_USER(T.S_CR,1)
		from IT_TASKS T
		where T.ID=@taskID 
	
	declare @t table (EMPID int)

	if @S_S_NEW=1
		insert into @t (EMPID)
		select N.EMPID
			from IT_KB_NOTIFICATIONS N
			where (isnull(N.ONLYMY,0)=0 or (isnull(N.ONLYMY,0)=1 and N.EMPID=@tEmpId))
				and N.NEW_TASKS=1
				and N.EMPID<>@curEmpId
	else
		insert into @t (EMPID)
		select distinct N.EMPID
			from IT_KB_NOTIFICATIONS N
				join IT_KB_NOTIFICATIONS_S S on N.ID=S.NOTIFID
			where (isnull(N.ONLYMY,0)=0 or (isnull(N.ONLYMY,0)=1 and N.EMPID=@tEmpId))
				and S.STATEID=@S_S_NEW
				and N.EMPID<>@curEmpId

	declare @stNameOld nvarchar(100), @stNameNew nvarchar(100)

	set @stNameOld=dbo.DEF_STATE_NAME_EN(@S_S_OLD)
	set @stNameNew=dbo.DEF_STATE_NAME_EN(@S_S_NEW)
		
	declare @subj nvarchar(1024), @body nvarchar(max)

	if @S_S_OLD<>0
	begin

		set @subj = 'KB' + CAST(@taskID as nvarchar(10)) + ': ' +
				'State changed'
		set @body = 'Dear all,<br><br>' +
					'<b>KB Task <a href = "a2l:\\Link=doc.it_task.'+LTRIM(rtrim(str(@taskID)))+'">' + CAST(@taskID as nvarchar(10)) + '</a></b>: state was changed by ' + @modUserName + '.<br><br>' +
					'<b>Subject</b>: ' + isnull(@tSubj,'Not set') + '<br><br>' +
					'<b>Old value</b>: ' + isnull(cast(@stNameOld as nvarchar(100)),'Not set') + ', <b>New value</b>: ' + isnull(cast(@stNameNew as nvarchar(100)),'Not set') + '<br><br>' +
					'<b>Ticket Number</b>: ' + ISNULL(' <a href="http://ipgl-bu-support.ipgphotonics.com/WorkOrder.do?woMode=viewWO&woID=' + @tickNum + '&fromListView=true">' + @tickNum + '</a>','Not set')
	end
	else
	begin
		set @subj = 'KB' + CAST(@taskID as nvarchar(10)) + ': ' +
				'New task added'
		set @body = 'Dear all,<br><br>' +
				'<b>New KB Task <a href = "a2l:\\Link=doc.it_task.'+LTRIM(rtrim(str(@taskID)))+'">' + CAST(@taskID as nvarchar(10)) + '</a></b> was added by ' + @crUserName + '.<br><br>' +
				'<b>Subject</b>: ' + isnull(@tSubj,'Not set') + '<br><br>' +
				'<b>Ticket Number</b>: ' + ISNULL(' <a href="http://ipgl-bu-support.ipgphotonics.com/WorkOrder.do?woMode=viewWO&woID=' + @tickNum + '&fromListView=true">' + @tickNum + '</a>','Not set')
	end

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