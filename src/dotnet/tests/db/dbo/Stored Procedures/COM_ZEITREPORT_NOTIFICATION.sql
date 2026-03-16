CREATE PROCEDURE [dbo].[COM_ZEITREPORT_NOTIFICATION] @UserID int, @aMode int
AS
BEGIN
  set nocount on

  declare @now datetime
  set @now = GETDATE()
  
  if dbo.COM_DAY_OF_WEEK(@now) <> 5  
  begin
    print 'exit (not friday)'
    set nocount off
    return
  end
  
  if datepart(hour,@now) <> 17 
  begin
    print 'exit (not 17 o`clock)'
    set nocount off
    return
  end

  declare @nowDate date  
  set @nowDate = CAST(@now as date)
  
  if exists (select G.DD from MSG_LAST_DELIVERY_DATES G where G.DELIVERYTYPE = 1999 and G.DEPID = 0 and G.DD = @nowDate)
  begin
    print 'exit (today already done)'
    set nocount off
    return
  end
  
  declare @weekNN int = year(@nowDate)*100+datepart(iso_week,@nowDate)

  declare @missedReports table (EMPLID int not null,DEPID int not null)
  
  insert into @missedReports(EMPLID,DEPID)
  select A.ID, A.DEPID 
  from COM_EMPLOYEE A with (nolock)
  where A.S_S = 1
    and A.ISTEMP = 1
    and A.ZAFID is not null
    and not exists (select B.ID from COM_ZEITARBEITREPORT B with (nolock) where B.EMPLID = A.ID and B.WEEKN = @weekNN) 
    and dbo.MSG_DELIVERYTYPE_INDEP_EXISTS(1999,A.DEPID) = 1
  
  
  declare @oneDepID int
  declare @msgBody nvarchar(max)
  
  declare @i int = 0
  while (1=1)
  begin
    set @i = @i + 1
    if @i > 300
      break
    
    set @oneDepID = null
    set @msgBody = null
    
	select top 1 @oneDepID = DEPID from @missedReports
    if @oneDepID is null
      break
      
    select @msgBody = 'Dear All,<br><br>'
    select @msgBody = @msgBody + 'At the moment "Timesheet" documents by current week are missed by the following employee:<br><br>'
    
    select @msgBody = @msgBody + B.NAME + ' (' + isnull(C.NAME,'NA') + ')<br>'
    from @missedReports A
    left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
    left join COM_ZEITAFIRMA C with (nolock) on C.ID = B.ZAFID
    where A.DEPID = @oneDepID
    order by B.NAME
      
    delete from @missedReports where DEPID = @oneDepID
    
    select @msgBody = @msgBody + '<br><br>'
    select @msgBody = @msgBody + 'Checking time: '+dbo.COM_FORMAT_DATETIME(@now,1)
    select @msgBody = @msgBody + '<br><br>Please do not reply.<br>Production Database'
    
    exec MSG_SEND_TODELIVERYGROUP @UserID, 1999, @oneDepID, 'Notification about missed "Timesheet" documents', @msgBody
    
  end
  
  insert into MSG_LAST_DELIVERY_DATES (DELIVERYTYPE,DEPID,DD)
  values (1999,0,@nowDate)
  
  print 'work done'

END