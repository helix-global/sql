CREATE PROCEDURE [dbo].[PM_LABOR_EXPECTED_KB3824] @UserID int, @aMode int
AS
BEGIN
  /*KB3824 п.3*/
  set nocount on

  declare @now datetime
  set @now = GETDATE()
  declare @nowDate date  
  set @nowDate = CAST(@now as date)
  
  
  if datepart(hour,@now) < 7 or datepart(hour,@now) > 11 or dbo.COM_IS_WORKDAY(@nowDate,1) <> 1
  begin
    set nocount off
    return
  end
  
  
  if exists (select * from PM_KB3824_NOTIFICATION_DATES where NTYPE = 3 /*п.3 KB3824*/ and LASTDD >= @nowDate)
  begin
    set nocount off
    return
  end
  
  declare @afTasks table (ID int)
  
  insert into @afTasks (ID)
  select A.ID
  from PM_TASK A with(nolock)
  where A.S_S = 1 
    and A.LABOR_EST is null
    and A.JIRA_ID is null
    and isnull(A.EXCLFROMPLAN,0) <> 1
	and dbo.PM_TASK_LABOREST(A.ID,0) is null /* KB4239 p.1 */
    
    
  declare @recipients table (TASKID int, EMPLID int)
  
  /*исполнители*/
  insert into @recipients(TASKID,EMPLID)
  select A.VNESHID,B.ID 
  from PM_TASK_ASSIGNEE A with(nolock)
  left join COM_EMPLOYEE B with(nolock) on B.ID = A.EMPLID 
  where A.VNESHID in (select ID from @afTasks)
    and B.EMAIL is not null
  
  
  /*нач.отдела  какого отдела? - в ТЗ ничего не сказано, возьмем пока RESPDEP*/
  insert into @recipients(TASKID,EMPLID)
  select A.ID,B.ID
  from PM_TASK A with(nolock)
  left join COM_EMPLOYEE B with(nolock) on B.DEPID = A.RESPDEP and B.ROLEINDEP in (100/*head*/)
  where A.ID in (select ID from @afTasks)
    and B.ID is not null
    and B.EMAIL is not null
  
  
    declare @subj nvarchar(max) = 'Labor Estimates (h) are missing'
	declare @empl int
  
	declare cur cursor local read_only for select distinct EMPLID from @recipients where EMPLID <> 1
	open cur
	WHILE 1=1
	BEGIN
		FETCH NEXT FROM cur INTO @empl;
		IF @@FETCH_STATUS<>0 BREAK;
	    
		
		 declare @mess nvarchar(max) = ''
         set @mess = 'Dear All,<br><br>'
         
         /*set @mess = @mess + cast(@empl as nvarchar(50))+'<br>'*/
         
         set @mess = @mess + 'Please find below the information about Tasks where Labor Estimate (h) field is empty<br><br>'
		 set @mess = @mess + '<font size="-2"><table width="1000" cellspacing = "1" border="1" bordercolor="#ffffff">'
		 set @mess = @mess + '<thead><th>Task</th><th>Employee</th></thead>'

		 declare @s	nvarchar(max) = ''
		 select @s = @s + '<tr><td><a href="a2l:\\Link=doc.pm_task.' + convert(varchar,A.ID) +'">'+isnull(A.SUBJ,'NA')+'</a></td><td>'+isnull(dbo.PM_TASK_ASSIGNEE_STR(A.ID,0),'')+'</td></tr>'
		 from PM_TASK A with(nolock)
		 where A.ID in (select TASKID from @recipients where EMPLID = @empl)

         set @mess = @mess + @s + '</table></font><br><br>'
         set @mess = @mess + 'Please do not answer this e-mail.<br>'
         set @mess = @mess + 'Production Database'

		 /*exec MSG_SEND_TOEMPLOYEE @UserID, 1, @subj, @mess */
	     exec MSG_SEND_TOEMPLOYEE @UserID, @empl, @subj, @mess 
	    
	END
	close cur;
	deallocate cur;
  
    update PM_KB3824_NOTIFICATION_DATES set LASTDD = @nowDate where NTYPE = 3  /*п.3 KB3824*/
    if @@rowcount = 0
      insert into PM_KB3824_NOTIFICATION_DATES (NTYPE,LASTDD) values (3,@nowDate)
    
	set nocount off
END