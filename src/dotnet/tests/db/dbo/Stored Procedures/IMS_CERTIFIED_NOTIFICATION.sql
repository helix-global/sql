CREATE PROCEDURE [dbo].[IMS_CERTIFIED_NOTIFICATION] @UserID int, @aMode int
AS
BEGIN
  set nocount on

  declare @now datetime
  set @now = GETDATE()
  
  if datepart(hour,@now) <> 18 
  begin
    set nocount off
    return
  end
  
  if (dbo.DEF_SYS_CONST_STR('com_remotelocation_code', '') <> 'IPGL')
  begin
    set nocount off
    return
  end

  declare @nowDate date  
  set @nowDate = CAST(@now as date)
  
  declare @lastDD date
  select top 1 @lastDD = LASTDD from IMS_CERTIFIED_NOTIFICATION_LASTDD /*лежит дата последней рассылки, а не дата за которую формировалась последняя рассылка*/
  
  if isnull(@lastDD,'20000101') >= @nowDate 
  begin
    set nocount off
    return
  end
  

  declare @prevDay date
  set @prevDay = dateadd(day,-1,@nowDate)
  
  declare @trainings table (ID int not null)
  
  insert into @trainings (ID)
  select A.ID 
  from IMS_TRAINING A with (nolock) 
  left join IMS_TRAINING_SCHEDULE B with (nolock) on B.ID = A.SCHEDULEID
  where A.CERTIFIED_D = @prevDay /*or A.ID in (93,96,95)*/
    and isnull(B.TRAINING_INSIDEDEP,0) <> 1  /*KB3510*/
  
  if exists (select ID from @trainings)
  begin

	  declare @mess nvarchar(max)
	  set @mess = 'Liebes HR-Team,<br><br>folgende Mitarbeiter haben erfolgreich eine Schulung beendet:<br><br>'
	  set @mess = @mess + '<table width="800" cellspacing = "1" bgcolor="#fefefe" border="1" bordercolor="#ffffff">'
	  set @mess = @mess + '<tr><th>Employee Name</th><th>Department</th><th>Date</th><th>Qualification Name</th><th>Certificate</th></tr>'
	  
	  select @mess = @mess + '<tr><td>'+B.NAME+'</td><td>'+C.NAME+'</td><td>'+isnull(convert(nvarchar,A.COMPLETED_D,104),'')+'</td><td>'+D.NAME+'</td><td>'+dbo.IMS_CERTIFIED_NOTIFICATION_FILES_HTM(A.ID,0)+'</td></tr>'
	  from IMS_TRAINING A with (nolock) 
	  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
	  left join COM_DEPARTMENTS C with (nolock) on C.ID = B.DEPID
	  left join IMS_TRAINING_PLAN D with (nolock) on D.ID = A.TRAININGPLANID
	  where A.ID in (select ID from @trainings)
	  
	  set @mess = @mess + '</table><br><br>This message is sent automatically, please do not reply.<br>Production Database'
	  
	  declare @messID int = null
	  declare @msSubj nvarchar(200) = 'Schulung beendet'
	  declare @msTo nvarchar(200) = 'EmployeeIsCertifiedByIMS@ipgphotonics.com' /*KB3509 'personalabteilung@ipgphotonics.com'*/
	  declare @msToBCC nvarchar(200) = null /*'dnorkin@ipgphotonics.com'*/
	  
	  INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR ,MSGBCC ) 
	  values (0,newid(),@msTo,@msSubj,@mess,getdate(),@UserID, @msToBCC)
	      
	  set @messID = @@identity

	  insert into MSG_OUT_ATTACHEMENTS (GID,VNESHID,FILENAME,FILEDATE,FILESIZE,FILEBLOB/*,CONTENTID,CONTENTTYPE*/)  /*ссылки из тела письма на attachment не работают*/
	  select newid(),@messID,A.FILENAME,A.FILEDATE,A.FILESIZE,A.FILEBLOB/*,replace(cast(A.GID as nvarchar(50)),'-','')+'@1','application/pdf'*/
		from IMS_TRAINING_FILES A with (nolock) 
	   where A.VNESHID in (select ID from @trainings)

	  update MSG_OUTGOING set S_S = 1 where MSG_OUTGOING.ID = @messID  

  end

  update IMS_CERTIFIED_NOTIFICATION_LASTDD set LASTDD = @nowDate
  if @@rowcount = 0
    insert into IMS_CERTIFIED_NOTIFICATION_LASTDD (LASTDD) values (@nowDate)

  print 'work done'

END