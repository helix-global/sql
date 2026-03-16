CREATE PROCEDURE [dbo].[MSG_FA_APPR_SUBSCRIPTION] 
(
     @FRID INT, @UserID int 
)
AS
BEGIN

    set nocount on

    declare @S_S int, @S_S_new int, @isSent int

    select @S_S = S_S, @isSent = NOTIFICATION_APPROVAL_IS_SENT
    from FC_REPORT 
    where ID=@FRID 

    if @isSent=1 or @S_S<>1000104
        return
        
    declare @DeliveryType int = 1330
    declare @DepID int
    declare @FromDepID int
    declare @sFRnumb nvarchar(300)
    declare @sFRnumb2 nvarchar(300)
    declare @sSubj nvarchar(300)
    declare @sBody nvarchar(max)
    declare @mImportance int
    declare @SN nvarchar(50)
    declare @ModelCode nvarchar(50)
    declare @ModelName nvarchar(200)

    select @sFRnumb = 'FR-'+C.CODE+'-'+ltrim(rtrim(str(A.ID)))
              ,@sFRnumb2 = dbo.FC_REPORT_NUMBER(A.RMA_TYPE,A.RMA)
              ,@DepID = B.DEPID
              ,@SN = A.SN
              ,@ModelCode = B.CODE
              ,@ModelName = B.NAME
              ,@FromDepID = A.FROMDEPID
              --,@UserID=A.USER4ID
        from FC_REPORT A 
        left join PR_MODELS B on B.ID = A.MODELID
        left join COM_DEPARTMENTS C on C.ID = B.DEPID
        where A.ID = @FRID
    
    declare @vTo nvarchar(1024)
    select @vTo = isnull(@vTo,'') + E1.EMAIL + '; '
    from FC_FA_APPROVE_SUBSCRIPTION F
        join FC_FA_APPROVE_SUBSCRIPTION_D D on F.ID=D.VNESHID
        join COM_EMPLOYEE E on D.DEPARTMENTID=E.DEPID
        join DEF_USERS U on U.EMPLOYEEID=E.ID
        join FC_FA_APPROVE_SUBSCRIPTION_P P on F.ID=P.VNESHID
        join COM_EMPLOYEE E1 on P.EMPLOYEEID=E1.ID
    where F.DEPID=@FromDepID and U.ID=@UserID

	/* KB2950 - SG - Corrections to automatical notifications about FR approval */
	/* PART 1 of Task - add external emails for approve notification delivery from settings in PDB */
	select @vTo = isnull(@vTo,'') + M.EMAIL + '; '
    from FC_FA_APPROVE_SUBSCRIPTION F
        join FC_FA_APPROVE_SUBSCRIPTION_D D on F.ID=D.VNESHID
        join COM_EMPLOYEE E on D.DEPARTMENTID=E.DEPID
        join DEF_USERS U on U.EMPLOYEEID=E.ID
        join FC_FA_APPROVE_SUBSCRIPTION_P P on F.ID=P.VNESHID
        join COM_EMPLOYEE E1 on P.EMPLOYEEID=E1.ID
		join FC_FA_APPROVE_SUBSCRIPTION_EXT_MAIL M on M.VNESHID = F.ID
    where F.DEPID=@FromDepID and U.ID=@UserID


    if isnull(@vTo,'')=''
        return
        
    if len(@sFRnumb2) > 0
        set @sFRnumb = @sFRnumb+', '+@sFRnumb2

    set @sBody = 'Dear All,<br><br>The failure report <a href = "a2l:\\Link=doc.fc_report.'+LTRIM(rtrim(str(@FRID)))+'">'+@sFRnumb+'<a>'
        
    set @sSubj = @sFRnumb + ' approved'
    set @sBody = @sBody + ' was approved.<br/><br/>'
    
    set @sBody = @sBody + '<b>SN</b>: ' + @SN + '<br/>'
    set @sBody = @sBody + '<b>Model Code:</b> ' + @ModelCode + '<br/>'
    set @sBody = @sBody + '<b>Model Name:</b> ' + @ModelName 
        
    set @sBody = @sBody +'<br><br>Please, do not answer this e-mail.<br>Production Database'     

    --select @vTo
    --print @sBody 
    
    insert into MSG_OUTGOING (S_S, GID, MSGTO, MSGSUBJ, MSGBODY, S_CDT, S_CR) 
    values (1, NEWID(), @vTo , @sSubj,  @sBody, GETDATE(), @UserID) 
      
    update FC_REPORT set NOTIFICATION_APPROVAL_IS_SENT=1
        where ID=@FRID 

    set nocount off 
END