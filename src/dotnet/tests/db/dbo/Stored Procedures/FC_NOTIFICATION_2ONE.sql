CREATE PROCEDURE [dbo].[FC_NOTIFICATION_2ONE] 
  @deliveryID int,@deliveryType int
AS
BEGIN
  set nocount on
  DECLARE @numb_of_email_today int
  DECLARE @numb_of_comp_req_analysis int
  DECLARE @subject varchar(100)
  DECLARE @body varchar(max)
  declare @now datetime
  declare @DepID int
  declare @recipient nvarchar(1024)
  declare @cc nvarchar(1024)
  
  set @now = getdate()
  SET @subject='Analysis date has expired'
  
  SELECT @numb_of_email_today=COUNT(*) 
    FROM MSG_OUTGOING 
  WHERE DELIVERYID = @deliveryID
    AND CONVERT(date, S_CDT) = CONVERT (date, GETDATE()) 
    and MSGDELIVERYID = @deliveryType

  IF @numb_of_email_today > 0
  begin
    set nocount off 
    return
  end
  
  select @DepID = A.DEPID
        ,@recipient = dbo.MSG_DELIVERY_TO(A.ID,0)
        ,@cc = dbo.MSG_DELIVERY_TO(A.ID,1)
  from MSG_DELIVERYLIST A with (nolock) 
  where A.ID = @deliveryID
	  
  declare @frs table (ID int,MODELID int, SN nvarchar(50), USER3DT datetime, RMA nvarchar(50), TTEXT nvarchar(max))
	  
  insert into @frs (ID,MODELID,SN,USER3DT,RMA)
  SELECT A.ID,A.MODELID,A.SN,A.USER3DT,dbo.FC_REPORT_NUMBER(A.RMA_TYPE,A.RMA) as RMA
	FROM FC_REPORT A with (nolock)
   WHERE A.MODELID in (select ID from dbo.PR_DEP_MODELS(@DepID))
	 AND A.REQUESTEDACTIONS in (1,2,6) 
	 AND A.USER2DT IS NULL 
	 and A.S_S = 1
	 and A.USER3DT is not null /*дата приема*/
	 and datediff(day,A.USER3DT,@now) > (select isnull(J.FRANALYZEMISSEDDAYS,6) from COM_DEPARTMENTS J with(nolock) where J.ID = @DepID) /*6*//*KB3548*/
	 
  SELECT @numb_of_comp_req_analysis = COUNT(*) from @frs	 
  
  IF @numb_of_comp_req_analysis > 0
  BEGIN
  

	SET @body='Dear All,<br><br> there are ' + CONVERT(varchar,@numb_of_comp_req_analysis) + ' failure reports with expired analysis date.<br><br>'
	
    SET @body = @body + '<font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
    set @body = @body + '<tr><th>ID</th><th>Model</th><th>SN</th><th>Date of receipt</th><th>Service number</th></tr>'
    
    update @frs set TTEXT = '<tr><td><a href = "a2l:\\Link=doc.fc_report.'+LTRIM(rtrim(str(ID)))+'">'+LTRIM(rtrim(str(ID)))+'</a></td>'
    update @frs set TTEXT = TTEXT + '<td>' +(select B.NAME from PR_MODELS B with (nolock) where B.ID = "@frs".MODELID)+'</td>'
    update @frs set TTEXT = TTEXT + '<td>'+SN+'</td>'
    update @frs set TTEXT = TTEXT + '<td>'+convert(nvarchar,USER3DT,104)+'</td>'
    update @frs set TTEXT = TTEXT + '<td>'+RMA+'</td></tr>'

    
    select @body = @body + A.TTEXT
    from @frs A order by A.ID

    set @body = @body + '</table></font>'
	
	SET @body=@body + '<br><br><br>Please, do not answer this e-mail.<br>'
	SET @body=@body + 'Production Database'
	
	INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR, MSGDELIVERYID, DELIVERYID, MSGCC, MSGIMP) VALUES (1, NEWID(), @recipient, @subject, @body, GETDATE(), 0, @deliveryType, @deliveryID, @cc, 1)
  END
  set nocount off

END