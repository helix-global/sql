CREATE PROCEDURE [dbo].[PM_DUEDATE_EXPIRED_KB3824] @UserID int, @aMode int
AS
BEGIN
  /*KB3824 п.2*/
  set nocount on

  declare @now datetime
  set @now = GETDATE()
  
  if datepart(hour,@now) < 8 or datepart(hour,@now) > 13 
  begin
    set nocount off
    return
  end
  
  declare @nowDate date  
  set @nowDate = CAST(@now as date)
  
  if exists (select * from PM_KB3824_NOTIFICATION_DATES where NTYPE = 2 /*п.2 KB3824*/ and LASTDD >= @nowDate)
  begin
    set nocount off
    return
  end
  
  declare @expiredTasks table (ID int, S_CR int)
  
  insert into @expiredTasks (ID,S_CR)
  select A.ID,A.S_CR
  from PM_TASK A with(nolock)
  where A.S_S = 1 
    and A.DUEDATE is not null
    and @nowDate > cast(A.DUEDATE as date) 
    /*KB3947 and dateadd(day,-1,@nowDate) = cast(A.DUEDATE as date)*/ /* или слать каждый день? в ТЗ сказано "когда просрочился" т.е. в этот момент ? */
    and A.JIRA_ID is null /*KB3967*/
    and isnull(A.EXCLFROMPLAN,0) <> 1 /*KB3967*/
    
    
  declare @recipients table (TASKID int, EMPLID int)
  
  /*авторы*/
  insert into @recipients(TASKID,EMPLID)
  select A.ID,B.ID
  from @expiredTasks A
  left join DEF_USERS U with(nolock) on U.ID = A.S_CR
  left join COM_EMPLOYEE B with(nolock) on B.ID = U.EMPLOYEEID
  where B.ID is not null
    and B.EMAIL is not null
  
  /*исполнители*/
  insert into @recipients(TASKID,EMPLID)
  select A.VNESHID,B.ID 
  from PM_TASK_ASSIGNEE A with(nolock)
  left join COM_EMPLOYEE B with(nolock) on B.ID = A.EMPLID 
  where A.VNESHID in (select ID from @expiredTasks)
    and B.EMAIL is not null
  
  
  /*нач.отдела  какого отдела? - в ТЗ ничего не сказано, возьмем пока RESPDEP*/
  insert into @recipients(TASKID,EMPLID)
  select A.ID,B.ID
  from PM_TASK A with(nolock)
  left join COM_EMPLOYEE B with(nolock) on B.DEPID = A.RESPDEP and B.ROLEINDEP in (100/*head*/)
  where A.ID in (select ID from @expiredTasks)
    and B.ID is not null
    and B.EMAIL is not null
  
  
    declare @subj nvarchar(max) = 'Expired Due Dates'
	declare @empl int
  
	declare cur cursor local read_only for select distinct EMPLID from @recipients where EMPLID <> 1
	open cur
	WHILE 1=1
	BEGIN
		FETCH NEXT FROM cur INTO @empl;
		IF @@FETCH_STATUS<>0 BREAK;
	    
		
		 declare @mess nvarchar(max) = ''
         set @mess = 'Dear All,<br><br>'
         
         set @mess = @mess + 'Please find below the information about Tasks which Due Dates are expired<br><br>'
		 set @mess = @mess + '<font size="-2"><table width="1000" cellspacing = "1" border="1" bordercolor="#ffffff">'
		 set @mess = @mess + '<thead><th>Task</th><th>Employee</th><th>Due Date</th></thead>'

		 declare @s	nvarchar(max) = ''
		 select @s = @s + '<tr><td><a href="a2l:\\Link=doc.pm_task.' + convert(varchar,A.ID) +'">'+isnull(A.SUBJ,'NA')+'</a></td><td>'+isnull(dbo.PM_TASK_ASSIGNEE_STR(A.ID,0),'')+'</td><td>'+isnull(convert(nvarchar,A.DUEDATE,104),'NA')+'</td></tr>'
		 from PM_TASK A with(nolock)
		 where A.ID in (select TASKID from @recipients where EMPLID = @empl)
		 order by A.DUEDATE

         set @mess = @mess + @s + '</table></font><br><br>'
         set @mess = @mess + 'Please do not answer this e-mail.<br>'
         set @mess = @mess + 'Production Database'

		 /*exec MSG_SEND_TOEMPLOYEE @UserID, 1, @subj, @mess */
	     exec MSG_SEND_TOEMPLOYEE @UserID, @empl, @subj, @mess 
	    
	END
	close cur;
	deallocate cur;
  
    update PM_KB3824_NOTIFICATION_DATES set LASTDD = @nowDate where NTYPE = 2  /*п.2 KB3824*/
    if @@rowcount = 0
      insert into PM_KB3824_NOTIFICATION_DATES (NTYPE,LASTDD) values (2,@nowDate)
    
	set nocount off

END