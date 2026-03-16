-- KB5391:2025-04-28: Using [PM_TASK_TIME].[MINUTES] if it available.
CREATE PROCEDURE [dbo].[PM_TIME_TRACK_REMINDER] @UserID int, @aMode int
AS
BEGIN
  set nocount on

  declare @now datetime
  set @now = GETDATE()
  
  if datepart(hour,@now) < 8 or datepart(hour,@now) > 12 
  begin
    set nocount off
    return
  end
  
  declare @nowDate date  
  set @nowDate = CAST(@now as date)
  
  declare @prevWorkDay date = @nowDate
  
  set @prevWorkDay = dateadd(day,-1,@prevWorkDay)
  declare @i int = 0

  while dbo.COM_IS_WORKDAY(@prevWorkDay,1) <> 1
  begin
  
	  set @prevWorkDay = dateadd(day,-1,@prevWorkDay)
	  
	  set @i = @i + 1
	  if (@i > 100)
	  begin
		raiserror('#ECannot define previous working date',16,0)
		set nocount off  
		return 
	  end	
		
  end
  
  set @i = 0
  
  while (@i < 10)   /*за один вызов процедуры формировать max 10 штук*/
  BEGIN
      set @i = @i + 1

      declare @settID int = null /*строка в PM_REMINDER_SETT_T, которой надо слать напоминание*/
    
      select top 1 @settID = A.ID from PM_REMINDER_SETT_T A with (nolock) where A.LASTNOTIFIED is null
      
      if @settID is null
      begin
         select top 1 @settID = A.ID from PM_REMINDER_SETT_T A with (nolock) where A.LASTNOTIFIED < @prevWorkDay  
      end   
  
      if @settID is null
	  begin
		set nocount off
		return
	  end
	  
	  declare @emplID int = null
	  declare @spisano decimal(16,2) = null
	  declare @available decimal(16,2) = null
	  declare @email nvarchar(250) = null
	  declare @emplName nvarchar(250) = null
	  
	  select @emplID = A.EMPLID
	        ,@spisano = (select sum(case when [_].[MINUTES] is not null then [_].[MINUTES] else round([_].[MHOUR]*60,0) end)/60.0 from [dbo].[PM_TASK_TIME] [_] with(nolock) where [_].[EMPLID]=[A].[EMPLID] and [_].[DD] = @prevWorkDay) 
	        ,@available = dbo.COM_ATTENDANCE_TIME2(null,A.EMPLID,@prevWorkDay) / 60
	        ,@email = B.EMAIL
	        ,@emplName = isnull(B.GIVENNAME,B.NAME)
	  from PM_REMINDER_SETT_T A with (nolock) 
	  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
      and exists (select PL.ID 
					from PM_TASK_ASSIGNEE PL with (nolock) 
					left join PM_TASK PM with (nolock) on PM.ID = PL.VNESHID
					left join PM_PROJECT PJ with (nolock) on PJ.ID = PM.PROJID
				   where PL.EMPLID = B.ID
					 and PJ.DBEG <= @prevWorkDay
					 and isnull(PJ.CLODEDATE,'40000101') >= @prevWorkDay
			  )  /*участвует в активных на эту дату проектах*/	 
	  where A.ID = @settID
   
      if @emplID = 1
      begin
        set @available = 8
        set @spisano = 7
      end
   
      if @emplID is not null and @email is not null and @available > 0 and @spisano < @available
      begin
      
         declare @subj nvarchar(max) = 'Project Management Reminder'
      
         declare @mess nvarchar(max) = ''
         set @mess = 'Dear '+@emplName+',<br><br>'
         set @mess = @mess + 'Please fill <a href = "a2l:\\Link=doc.pm_task_time">"Time Tracking" document</a> by project tasks you are involved in.<br><br>'
         set @mess = @mess + 'Date: '+convert(nvarchar,@prevWorkDay,103)+'<br><br>'
         set @mess = @mess + 'Working Time: '+convert(nvarchar,@available)+' hours<br>'
         set @mess = @mess + 'Tracked Time: '+convert(nvarchar,@spisano)+' hours<br><br>'
         set @mess = @mess + '<br>'
         set @mess = @mess + 'Please do not respond,<br>'
         set @mess = @mess + 'PDB'

         exec MSG_SEND @UserID, @email, null, @subj, @mess 
      
      end
      
      update PM_REMINDER_SETT_T set LASTNOTIFIED = @prevWorkDay where ID = @settID
    
  END 

END