CREATE PROCEDURE [dbo].[MSG_FA_CR_SUBSCRIPTION] 
(
	 @FRID INT, @UserID int	
)
AS
BEGIN

    set nocount on

	declare @S_S int, @S_S_new int, @isSent int

	select @S_S = S_S, @isSent = NOTIFICATION_IS_SENT
	from FC_REPORT 
	where ID=@FRID 

	if @isSent=1 or @S_S<>1
		return

    declare @DeliveryType int = 1330
    declare @DepID int
    declare @sFRnumb nvarchar(300)
    declare @sFRnumb2 nvarchar(300)
    declare @sSubj nvarchar(300)
    declare @sBody nvarchar(max)
    declare @mImportance int
	declare @SN nvarchar(50)
	declare @ModelCode nvarchar(50)
	declare @ModelName nvarchar(200)
	declare @frGID nvarchar(50)

	select @sFRnumb = 'FR-'+C.CODE+'-'+ltrim(rtrim(str(A.ID)))
		      ,@sFRnumb2 = dbo.FC_REPORT_NUMBER(A.RMA_TYPE,A.RMA)
			  ,@DepID = B.DEPID
			  ,@SN = A.SN
			  ,@ModelCode = B.CODE
			  ,@ModelName = B.NAME
			  ,@frGID = A.GID
		from FC_REPORT A 
		left join PR_MODELS B on B.ID = A.MODELID
		left join COM_DEPARTMENTS C on C.ID = B.DEPID
		where A.ID = @FRID
		
	if len(@sFRnumb2) > 0
		set @sFRnumb = @sFRnumb+', '+@sFRnumb2

    /*set @sBody = 'Dear All,<br><br>The failure report <a href = "a2l:\\Link=doc.fc_report.'+LTRIM(rtrim(str(@FRID)))+'">'+@sFRnumb+'<a>'*/
    /*01.09.2020 переключено на GID*/
	set @sBody = 'Dear All,<br><br>The failure report <a href = "a2l:\\Link=docg.fc_report.'+@frGID+'">'+@sFRnumb+'<a>'
		
	set @sSubj = @sFRnumb + ' created'
	set @sBody = @sBody + ' was created.<br/><br/>'
	
	set @sBody = @sBody + '<b>SN</b>: ' + @SN + '<br/>'
	set @sBody = @sBody + '<b>Model Code:</b> ' + @ModelCode + '<br/>'
	set @sBody = @sBody + '<b>Model Name:</b> ' + @ModelName 
		
	set @sBody = @sBody +'<br><br>Please, do not answer this e-mail.<br>Production Database'	  
	  
    exec MSG_SEND_TODELIVERYGROUP2 @UserID, @DeliveryType, @DepID, @sSubj, @sBody, @mImportance

	update FC_REPORT set NOTIFICATION_IS_SENT=1
		where ID=@FRID 

	
	set nocount off	
END