CREATE PROCEDURE [dbo].[PM_CHECK_KB4186] @UserID int
AS
BEGIN
  /*KB4186*/
  set nocount on

  declare @now datetime
  set @now = GETDATE()
  declare @nowDate date  
  set @nowDate = CAST(@now as date)
  
  --в 7 утра (до 10)
  if datepart(hour,@now) < 7 or datepart(hour,@now) > 10 or dbo.COM_IS_WORKDAY(@nowDate,1) <> 1
  begin
    set nocount off
    return
  end
  
  --раз в день
  if exists (select * from PM_KB3824_NOTIFICATION_DATES where NTYPE = 4186 /*KB4186*/ and LASTDD >= @nowDate)
  begin
    set nocount off
    return
  end
  
  

-- collecting tasks with desired conditions and creators (authors) 
declare @taskOwners table (USERID int, TASKID int, EMPLID int, TASKSUBJ nvarchar(max))
insert into @taskOwners (USERID, TASKID, EMPLID, TASKSUBJ)
select 
	T.S_CR, T.ID, U.EMPLOYEEID, T.SUBJ
from 
	PM_TASK T with (nolock)
	left join DEF_USERS U with (nolock) on U.ID = T.S_CR
where
	T.S_S = 2130069 /* Ready For Approval */
-- collecting tasks with desired conditions and creators (authors)



declare @subj nvarchar(max) = '[PDB-PM] Tasks require approval'
declare @empl int
declare @mess nvarchar(max) = ''


--cursor for uniq Employee in collected tasks list  
declare cur cursor local read_only for select distinct EMPLID from @taskOwners where EMPLID <> 1
open cur
	WHILE 1=1
	BEGIN
		FETCH NEXT FROM cur INTO @empl;
		IF @@FETCH_STATUS<>0 BREAK;
	    
		--Сообщение
		set @mess  = ''
        set @mess = 'Dear All,<br><br>'
        set @mess = @mess + 'The tasks listed require an approval:<br><br>'
                  
		--список Tasks сос сылками в PDB
        declare @taskList nvarchar(MAX) = '<table><tr><th><b>Task subject<b></th><th><b>Link to open in PDB<b></th></tr>'
		select 
			@taskList = @taskList + 
				'<tr><td>' +isnull(A.TASKSUBJ,'NA') + '</td><td><a href="a2l:\\Link=doc.pm_task.' + convert(nvarchar, A.TASKID) +'"> Open in PDB</a></td></tr>' + CHAR(13) + CHAR(10)
		from 
			@taskOwners A
		where 
			EMPLID = @empl
		set @taskList = @taskList +  '</table>'
		--список Tasks сос сылками в PDB

		-- final body for mail
        set @mess = @mess + @taskList + '<br><br>'
        set @mess = @mess + 'Please do not answer this e-mail.<br>'
        set @mess = @mess + 'Production Database'

        --send to emplyee (task author) 
		exec MSG_SEND_TOEMPLOYEE @UserID, @empl, @subj, @mess 
		--test send to developer/programmer
        --exec MSG_SEND_TOEMPLOYEE @UserID, 3228, @subj, @mess 
    
	END
close cur;
deallocate cur;

--update last send date  
update PM_KB3824_NOTIFICATION_DATES set LASTDD = @nowDate where NTYPE = 4186 /*KB4186*/
if @@rowcount = 0 --если не проадейтилдась дата, 
  insert into PM_KB3824_NOTIFICATION_DATES (NTYPE,LASTDD) values (4186,@nowDate) --то просто вставляем запись с нужным кодом


set nocount off

  

END