CREATE PROCEDURE [dbo].[MSG_FA_SUBSCRIPTION] 
(
	 @FRID INT	
)
AS
BEGIN

    set nocount on

	DECLARE  @FAR_TODEPID INT 
	        ,@FAR_FROMDEPID INT 
			,@NOW DATETIME = GETDATE()
			,@FAR_S_S int
			,@FAR_CREATOR int
			,@depcode nvarchar(200)
			,@itemInfo nvarchar(400)

	SELECT @FAR_TODEPID = M.DEPID
		 , @FAR_S_S = A.S_S
		 , @FAR_CREATOR = A.S_CR
		 , @FAR_FROMDEPID = A.FROMDEPID
		 , @depcode = D.CODE
		 , @itemInfo = M.NAME + ' SN:'+ISNULL(A.SN,'NA')
	FROM FC_REPORT A with (nolock)
	left join PR_MODELS M with (nolock) ON M.ID = A.MODELID
	left join COM_DEPARTMENTS D with (nolock) on D.ID = M.DEPID
	WHERE A.ID = @FRID
	
	if @FAR_S_S not in (1000104,1000123) /*approved, closed*/
	begin
	  set nocount off
	  return
    end

	DECLARE @EMPLOYEE TABLE (EMAIL NVARCHAR(1024))
	
	insert into @EMPLOYEE (EMAIL)
	SELECT DISTINCT EMP.EMAIL
	FROM FC_FA_SUBSCRIBE S
	JOIN FC_FA_SUBSCRIBE_T ST ON S.ID = ST.VNESHID
	JOIN COM_EMPLOYEE EMP ON S.EMPLOYEEID = EMP.ID
	LEFT JOIN DEF_USERS USR ON S.EMPLOYEEID = USR.EMPLOYEEID
	WHERE ST.DEPARTMENTID = @FAR_TODEPID -- СОТРУДНИКИ, ПОДПИСАННЫЕ НА FA ЭТОГО ПОДРАЗДЕЛЕНИЯ
	AND	EMP.DEPID = @FAR_FROMDEPID -- СОТРУДНИКИ ТОЛЬКО ТОГО ПОДРАЗДЕЛЕНИЯ, КОТОРОЕ ИНИЦИИРОВАЛО FR
	AND	ISNULL(S.EXPDATE, @NOW) >= @NOW
	AND (USR.ID = @FAR_CREATOR OR USR.ID = 3)

    DECLARE @SENDTO NVARCHAR(1024)

	SELECT @SENDTO = 
	(SELECT
		EMAIL + ';' AS [text()]
	FROM @EMPLOYEE
	WHERE
		ISNULL(EMAIL, '') != ''
	FOR XML PATH('')
	)


	IF len(@SENDTO) > 1
	begin
	
		DECLARE @MSG NVARCHAR(1024)
		SELECT @MSG = 'Dear All,<br><br>The Failure Report <a href = "a2l:\\Link=doc.fc_report.'+LTRIM(rtrim(str(@FRID)))+'">'+CAST(@FRID AS NVARCHAR(20))+'</a> ('+@itemInfo+') was analyzed in '+@depcode+' department.<br><br>'  
		set @MSG = @MSG + 'If you wish to change your subscription details, please use this <a href = "a2l:\\Link=doc.fc_FA_subscription">link</a>.<br>'
		set @MSG = @MSG + 'Please, do not answer this e-mail.<br>Production Database'
	
		EXEC MSG_SEND 0, @SENDTO, null, 'Failure Analisys Subscription', @MSG
		
	end	
	
	set nocount off	
END