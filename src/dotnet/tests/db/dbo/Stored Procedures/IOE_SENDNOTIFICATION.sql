CREATE PROCEDURE [dbo].[IOE_SENDNOTIFICATION] @UserID int, @aMode int
AS
BEGIN
  /* KB3052 - периодическая рассылка про курсы Instruction Of Employee */

  set nocount on

  declare @now datetime
  set @now = GETDATE()
  
  if datepart(hour,@now) not in (8,9,10) 
  begin
    set nocount off
    return
  end

  declare @nowDate date  
  set @nowDate = CAST(@now as date)
  

  declare @settingID int
  
  select top 1 @settingID = A.ID 
    from IOE_NOTIFICATIONS A 
   where dbo.IOE_NOTISNOOSEDATE(isnull(A.LASTSEND,'19000101'), A.PERIODTYPW, A.PERIODN) <= @nowDate
     and exists (select K.ID from IOE_NOTI_COURSES K with(nolock) where K.VNESHID = A.ID)
     and exists (select K.ID from IOE_NOTI_RECIPIENTS K with(nolock) 
                   left join COM_EMPLOYEE L with(nolock) on L.ID = K.EMPLID
                  where K.VNESHID = A.ID
                    and L.EMAIL is not null)


  if @settingID is null
  begin
    set nocount off
    return
  end  

  declare @msgTo nvarchar(max)
  declare @msg nvarchar(max)

  set @msg = N'Reminder.<br>Please invite your employees for the annual instructions on the topics health and safety at work.<br>'+
  N'If you are not using the online instruction tool please use the instruction document G71-36262 Unterweisungshandbuch.<br>'+
  N'Thank you.<br>SE department.<br><br>Affected courses:<br>'
    
    
  select @msg = @msg + B.NAME + N'<br>'
  from IOE_NOTI_COURSES A with(nolock)
  left join IOE_TOPICS B with(nolock) on B.ID = A.COURSEID
  where A.VNESHID = @settingID
  
  select @msgTo = isnull(@msgTo,'') + case when len(@msgTo) > 3 then N'; ' else '' end + B.EMAIL
  from IOE_NOTI_RECIPIENTS A with(nolock)
  left join COM_EMPLOYEE B with(nolock) on B.ID = A.EMPLID
  where A.VNESHID = @settingID
    and B.EMAIL is not null
   
  if len(@msgTo ) > 3
  begin
	exec MSG_SEND2 @UserID, @msgTo, null, 'IoE Reminder', @msg
  end
		
  update IOE_NOTIFICATIONS set LASTSEND = @nowDate where ID = @settingID
  
  set nocount off

END