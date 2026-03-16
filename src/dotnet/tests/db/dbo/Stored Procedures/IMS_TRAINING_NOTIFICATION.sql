CREATE PROCEDURE [dbo].[IMS_TRAINING_NOTIFICATION] @UserID int, @aMode int
AS
BEGIN
  /* KB1881 - напоминание о тренинге за 7 дней и за 1 день */

  set nocount on

  declare @now datetime
  set @now = GETDATE()
  
  if datepart(hour,@now) not in (8,9) 
  begin
    set nocount off
    return
  end

  declare @nowDate date  
  set @nowDate = CAST(@now as date)
  
  declare @needNotify table (ID int not null primary key, NDAYS int not null)
    
  insert into @needNotify (ID, NDAYS)
  select A.ID, 1 
    from IMS_TRAINING A with (nolock) 
    left join IMS_TRAINING_SCHEDULE_DATES B with (nolock) on B.ID = A.SCHEDULEDATEID
    left join COM_EMPLOYEE C with (nolock) on C.ID = A.EMPLID
   where A.S_S = 2130032 /*planned*/
     and A.COMPLETED_D is null
     and A.NOTIFIED_1 is null
     and datediff(day,@nowDate,cast(B.DD as date)) = 1 
     and C.EMAIL is not null
     
  
  insert into @needNotify (ID, NDAYS)
  select A.ID, 7 
    from IMS_TRAINING A with (nolock) 
    left join IMS_TRAINING_SCHEDULE_DATES B with (nolock) on B.ID = A.SCHEDULEDATEID
    left join COM_EMPLOYEE C with (nolock) on C.ID = A.EMPLID
   where A.S_S = 2130032 /*planned*/
     and A.COMPLETED_D is null
     and A.NOTIFIED_7 is null
     and datediff(day,@nowDate,cast(B.DD as date)) = 7 
     and C.EMAIL is not null
     and not exists (select J.ID from @needNotify J where J.ID = A.ID)

  declare @daysN int
  declare @oneID int
  declare @oneEmplID int 
  declare @oneMessage nvarchar(max)

  declare nxx cursor local read_only for 
  select distinct ID,NDAYS from @needNotify
  open nxx 
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM nxx INTO @oneID,@daysN
    IF @@FETCH_STATUS<>0 BREAK;
    
    set @oneMessage = null
    
    select @oneEmplID = A.EMPLID
          ,@oneMessage = 'Dear '+isnull(C.GIVENNAME,C.NAME)+',<br><br>'+
         'The following training coming soon:<br><br>'+
         '<b>Date:</b> '+dbo.COM_FORMAT_DATETIME(B.DD,1)+'<br>'+
         '<b>Training:</b> '+isnull(T2130321.NAME,'NA')+'<br>'+   
         '<b>Qualification Name:</b> '+isnull(T2130332.NAME,'NA')+'<br>'+
         '<b>Qualification Type:</b> '+isnull(T2130327.NAME,'NA')+'<br><br><br>'+
         'Please do not reply,<br>Production Database'  
    from IMS_TRAINING A with (nolock) 
    left join IMS_TRAINING_SCHEDULE_DATES B with (nolock) on B.ID = A.SCHEDULEDATEID
    left join COM_EMPLOYEE C with (nolock) on C.ID = A.EMPLID
	left join IMS_TRAINING_SCHEDULE T2130321 with (nolock) on T2130321.ID = A.SCHEDULEID
	left join IMS_TRAINING_TYPE T2130327 with (nolock) on T2130327.ID = A.TRAININGTYPEID
	left join IMS_TRAINING_PLAN T2130332 with (nolock) on T2130332.ID = A.TRAININGPLANID
    where A.ID = @oneID
    
    if @oneMessage is not null
    begin
        /*
		exec MSG_SEND @UserID, 'dnorkin@ipgphotonics.com', null, 'Training Notification', @oneMessage
		*/
		
		exec MSG_SEND_TOEMPLOYEE @UserID, @oneEmplID, 'Training Notification', @oneMessage
		
		if @daysN = 1
		begin
			update IMS_TRAINING set NOTIFIED_1 = getdate() where ID = @oneID
		end 
		else if @daysN = 7
		begin	
			update IMS_TRAINING set NOTIFIED_7 = getdate() where ID = @oneID
		end
		
	end	
    
  END
  close nxx;
  deallocate nxx;   
  
  print 'work done'
  
  set nocount off

END