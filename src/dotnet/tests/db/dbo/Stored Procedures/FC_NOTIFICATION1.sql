CREATE PROCEDURE [dbo].[FC_NOTIFICATION1] 
  @recipient varchar(50),@DepID int, @dear varchar(50), @cc varchar(250)
AS
BEGIN
  DECLARE @numb_of_email_today int
  DECLARE @numb_of_comp_req_analysis int
  DECLARE @numb_of_comp_req_analysis_auth int
  DECLARE @subject varchar(100)
  DECLARE @body varchar(500)
  SET @subject='Analysis required'
  
  SELECT @numb_of_email_today=COUNT(*) 
    FROM MSG_OUTGOING 
  WHERE MSGTO = @recipient
    AND CONVERT(date, S_CDT) = CONVERT (date, GETDATE()) 
    and MSGDELIVERYID = 1

  IF @numb_of_email_today > 0 return
	  
  if @DepID = 196  /*KB1801*/
  begin

	  SELECT @numb_of_comp_req_analysis=COUNT(*) 
		FROM FC_REPORT A with (nolock)
	   WHERE A.MODELID in (select ID from dbo.PR_DEP_MODELS(@DepID))
		 AND A.REQUESTEDACTIONS in (1,2,6) 
		 AND A.USER2DT IS NULL 
		 and A.S_S = 1
		 and A.USER1DT is not null  /*KB1801*/
  
  end
  else
  begin	  
	  
	  SELECT @numb_of_comp_req_analysis=COUNT(*) 
		FROM FC_REPORT A with (nolock)
	   WHERE A.MODELID in (select ID from dbo.PR_DEP_MODELS(@DepID))
		 AND A.REQUESTEDACTIONS in (1,2,6) 
		 AND A.USER2DT IS NULL 
		 and A.S_S = 1
	 
  end
  
  IF @numb_of_comp_req_analysis > 0
  BEGIN
	SELECT @numb_of_comp_req_analysis_auth=COUNT(*) 
	  FROM FC_REPORT A with (nolock)
	 WHERE A.MODELID in (select ID from dbo.PR_DEP_MODELS(@DepID))
	   AND A.REQUESTEDACTIONS in (1,2,6) 
	   AND S_S = 1000103

	SET @body='Dear '+@dear+',<br><br> there are ' + CONVERT(varchar,@numb_of_comp_req_analysis) + ' failure reports need your failure analysis,<br><br>'
	SET @body=@body + 'there are ' + CONVERT(varchar,@numb_of_comp_req_analysis_auth) + ' failure reports need your analysis approval.<br><br><br>'
	SET @body=@body + 'Please, do not answer this e-mail.<br>'
	SET @body=@body + 'Production Database'
	
	INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR, MSGDELIVERYID, MSGCC) VALUES (1, NEWID(), @recipient, @subject, @body, GETDATE(), 0, 1, @cc)
  END
  

END