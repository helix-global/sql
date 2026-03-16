CREATE PROCEDURE [dbo].[PM_COMPLETED_KB3824] @UserID int, @aMode int
AS
BEGIN
  /*KB3824 п.4*/
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
  
  
  if exists (select * from PM_KB3824_NOTIFICATION_DATES where NTYPE = 4 /*п.4 KB3824*/ and LASTDD >= @nowDate)
  begin
    set nocount off
    return
  end
  
  declare @cmplTasks table (ID int, S_CR int)
  
  insert into @cmplTasks (ID,S_CR)
  select A.ID,A.S_CR
  from PM_TASK A with(nolock)
  where A.S_S = 2130066  /*completed*/
    
    
  declare @recipients table (TASKID int, EMPLID int)
  
  /*авторы*/
  insert into @recipients(TASKID,EMPLID)
  select A.ID,B.ID
  from @cmplTasks A
  left join DEF_USERS U with(nolock) on U.ID = A.S_CR
  left join COM_EMPLOYEE B with(nolock) on B.ID = U.EMPLOYEEID
  where B.ID is not null
    and B.EMAIL is not null
  
  
    declare @subj nvarchar(max) = 'List of Completed Tasks'
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
         
         set @mess = @mess + 'Please find below the information about Сompleted Tasks and that are required for further actions<br><br>'
		 set @mess = @mess + '<font size="-2"><table width="1000" cellspacing = "1" border="1" bordercolor="#ffffff">'
		 set @mess = @mess + '<thead><th>Task</th><th>Employee</th><th>State</th></thead>'

		 declare @s	nvarchar(max) = ''
		 /*select @s = @s + '<tr><td>'+isnull(A.SUBJ,'NA')+'</td><td></td><td>Completed</td></tr>'*/  /*KB4048*/
		 select @s = @s + '<tr><td><a href="a2l:\\Link=doc.pm_task.' + convert(varchar,A.ID) +'">'+isnull(A.SUBJ,'NA')+'</a></td><td></td><td>Completed</td></tr>'
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
  
    update PM_KB3824_NOTIFICATION_DATES set LASTDD = @nowDate where NTYPE = 4  /*п.4 KB3824*/
    if @@rowcount = 0
      insert into PM_KB3824_NOTIFICATION_DATES (NTYPE,LASTDD) values (4,@nowDate)
   
   set nocount off 

END