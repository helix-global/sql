CREATE PROCEDURE [dbo].[SM_REQUEST_ORDER_NOTIFICATION] @UserID int, @ScID int, @aMode int
AS
BEGIN
  set nocount on

    declare @soType nvarchar(350)
    declare @requestor nvarchar(250)
    declare @customer nvarchar(250)
    declare @scNum nvarchar(12)
    declare @empName nvarchar(200)
    declare @to nvarchar(500) = 'ipgl-rs@ipgphotonics.com'
    declare @cc nvarchar(900) = ''
    declare @messId int

    select @soType = dbo.DEF_ENUM_V_EN(2130030/*1000151 KB2860*/, null, A.RMA_SC_TYPE)
            , @requestor = C.NAME
            , @customer = C1.NAME
            , @scNum = A.ND
            , @empName = dbo.DEF_EMPLOYEE_NAME(@UserID)
        from SM_SERVICECASE A
            join COM_CUSTOMER C on A.CUSTID=C.ID
            join COM_CUSTOMER C1 on isnull(A.CUSTID_4SERVORD,A.CUSTID)=C1.ID
        where A.ID=@ScID

    declare @items nvarchar(max) = ''
    select @items = @items + isnull(B.NAME,'NA')+' - ' + isnull(A.SN,'NA')+' - '+isnull(B.CODE,'NA') + '<br>'
        from SM_SERVICECASE_ITEMS A with (nolock)
        left join PR_MODELS B with (nolock) on B.ID = A.MODELID
    where A.VNESHID = @ScID

    declare @atts nvarchar(max) = ''
    select @atts = @atts + M.FILE_NAME + '<br>'
        from SM_SCASE_REQUEST_ORDER_MAIL M
        where M.CASEID=@ScID and M.USERID=@UserID
        
    declare @emplEmail nvarchar(200)    
    declare @emplDepID int
    
    select @emplEmail = A.EMAIL
          ,@emplDepID = A.DEPID
    from COM_EMPLOYEE A with(nolock)
    where A.ID = dbo.DEF_EMPLOYEE(@UserID)

    declare @subj nvarchar(1024) =''
    declare @mess nvarchar(max) = N''
  
  
    set @subj = @soType + ' request from ' + @requestor + ' - ' + @customer + '##' + @scNum + '##'
  
    set @mess = @mess + N'Sehr geehrte Damen und Herren,'
    set @mess = @mess + N'<br>'
    set @mess = @mess + N'bitte erstellen Sie eine ' + @soType + N' für den ' + @scNum + '<br>'
    set @mess = @mess + '<br>'
    set @mess = @mess + @requestor + '<br>'
    set @mess = @mess + @customer + '<br><br>'
  
    set @mess = @mess + '<table width="600" cellspacing = "1" border="0">'          
    set @mess = @mess + '<tr><td valign="top">Items List:</td><td valign="top">'+@items+'</td></tr>'
    set @mess = @mess + '</table>'
    set @mess = @mess + '<br>'
  
    set @mess = @mess + '<table width="600" cellspacing = "1" border="0">'          
    set @mess = @mess + '<tr><td valign="top">Attachments:</td><td valign="top">'+@atts+'</td></tr>'
    set @mess = @mess + '</table>'
    set @mess = @mess + '<br>'
    

    set @mess = @mess + N'Mit freundlichen Grüßen<br>'
    set @mess = @mess + @empName
    set @mess = @mess + '<br><br>PDB Link to <a href = "a2l:\\Link=doc.sm_service_case.'+LTRIM(rtrim(str(@ScID)))+'">'+isnull(@scNum,'NA')+'</a>'


    if dbo.COM_USER_DEPARTMENT(@UserID)=170 /*PLA*/
        set @cc = 'pulsed-lasers-service@ipgphotonics.com'

    if dbo.COM_USER_DEPARTMENT(@UserID)=190 /*SG*/
        set @cc = 'support.europe@ipgphotonics.com'
        
    if @emplEmail is not null
    begin
    
       if len(@cc) > 1
       begin
         set @cc = @cc+'; '+@emplEmail
       end
       else
       begin
		 set @cc = @emplEmail
       end  
    
    end    
    
    if @emplDepID is not null /*KB3715*/
    begin
      declare @additionalCC nvarchar(max)
      select @additionalCC = dbo.MSG_DELIVERYTYPE_INDEP_RECIPIENTS(2401,@emplDepID,1)
      if @additionalCC is not null and len(@additionalCC)>1
      begin
       if len(@cc) > 1
       begin
         set @cc = @cc+'; '+@additionalCC
       end
       else
       begin
		 set @cc = @additionalCC
       end  
      end
    end
    
    INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR) 
    values (1, NEWID(), @to, @cc , @subj,  @mess, GETDATE(), @UserID)
  
    set @messId = SCOPE_IDENTITY()

    insert into MSG_OUT_ATTACHEMENTS (GID,VNESHID,FILENAME,FILEDATE,FILESIZE,FILEBLOB)
        select newid(),@messID,A.FILE_NAME,getdate(),A.FILE_SIZE,A.FILE_BLOB
            from SM_SCASE_REQUEST_ORDER_MAIL A
            where A.CASEID=@ScID and A.USERID=@UserID

    delete from SM_SCASE_REQUEST_ORDER_MAIL
        where CASEID=@ScID and USERID=@UserID

    set nocount off

END