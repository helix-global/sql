CREATE PROCEDURE [dbo].[SM_COMPETE_NOTIFICATION] @UserID int, @WoID int, @aMode int
AS
BEGIN
  set nocount on

/*  KB2535 */


  declare @subj nvarchar(1024)
  declare @mess nvarchar(max)
  declare @emplID int
  declare @woNN nvarchar(50)
  declare @model nvarchar(250)
  declare @sn nvarchar(50)
  declare @requestor nvarchar(250)
  declare @SCid int
  declare @SCrequestor nvarchar(250)
  declare @SCcontact nvarchar(250)
  declare @SCnd nvarchar(20)
  declare @street nvarchar(250)
  declare @postcode nvarchar(50)
  declare @city nvarchar(150)
  declare @country nvarchar(100)
  declare @contactName nvarchar(100)
  declare @contactPhone nvarchar(100)
  declare @contactEmail nvarchar(250)
  declare @startFromOffice datetime
  declare @schArrival datetime
  declare @schDeparture datetime
  declare @remark nvarchar(max)
  declare @woGID nvarchar(50)
  
  
  select @mess = 'Dear support-team, <br>'
        ,@emplID = A.EMPLID
        ,@woNN = A.NN
        ,@sn = isnull(C.SN,'NA')
        ,@model = isnull(D.NAME,'NA')
        ,@requestor = isnull(E.NAME,'NA')
        ,@SCid = A.SCASEID
        ,@SCrequestor = isnull(SCE.NAME,'NA')
        ,@SCcontact = isnull(SCC.NAME,'NA')
        ,@SCnd = isnull('##'+SC.ND+'##','')
        ,@street = isnull(A.ADR_STREET,'NA')
        ,@postcode = isnull(A.ADR_CODE,'NA')
        ,@city = isnull(A.ADR_CITY,'NA')
        ,@country = isnull(J.NAME,'NA')
        ,@contactName = isnull(F.NAME,'NA')
        ,@contactPhone = isnull(F.PHONE,'NA')
        ,@contactEmail = isnull(F.EMAIL,'NA')
        ,@startFromOffice = A.STARTTIMEFROMOFFICE
        ,@schArrival = A.SH_DBEG
        ,@schDeparture = A.SH_DEND
        ,@remark = isnull(A.REMARK,'')
        ,@woGID = A.GID
  from SM_WORKORDER A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
  left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
  left join PR_MODELS D with (nolock) on D.ID = C.MODELID
  left join COM_CUSTOMER E with (nolock) on E.ID = A.CUSTID
  left join SM_SERVICECASE SC with (nolock) on SC.ID = A.SCASEID
  left join COM_CUSTOMER SCE with (nolock) on SCE.ID = SC.CUSTID
  left join COM_CUST_CONTACTS SCC with (nolock) on SCC.ID = SC.CONTACTID
  left join COM_CUST_CONTACTS F with (nolock) on F.ID = A.CONTACTID
  left join COM_COUNTRIES J with (nolock) on J.ID = A.ADR_COUNTRY
  where A.ID = @WoID
  
  if @emplID is null
  begin
    set nocount off
    return
  end
  
  set @subj = 'The work order completed. '+@woNN+' - '+@model+' - '+@sn+' - '+@requestor+' '+@SCnd
  
  set @mess = @mess + '<br>'
  set @mess = @mess + @woNN+' is completed<br>'
  set @mess = @mess + '<br>'
  
  declare @items nvarchar(max) = ''
  select @items = @items + isnull(B.NAME,'NA')+' - ' + isnull(A.SN,'NA')+' - '+isnull(B.CODE,'NA') + '<br>'
  from SM_SERVICECASE_ITEMS A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.VNESHID = @SCid
  
  set @mess = @mess + '<table width="600" cellspacing = "1" border="0">'          
  set @mess = @mess + '<tr><td valign="top">Items:</td><td valign="top">'+@items+'</td></tr>'
  set @mess = @mess + '</table>'
  set @mess = @mess + '<br>'
  
  set @mess = @mess + '<table width="600" cellspacing = "1" border="0">'          
  set @mess = @mess + '<tr><td valign="top">Requestor:</td><td valign="top">'+@SCrequestor+'</td></tr>'
  set @mess = @mess + '<tr><td valign="top">Contact:</td><td valign="top">'+@SCcontact+'</td></tr>'
  set @mess = @mess + '</table>'
  set @mess = @mess + '<br>'
  
  set @mess = @mess + '<table width="1000" cellspacing = "1" border="0">'
  set @mess = @mess + '<tr><td valign="top">Location of service intervention:</td><td valign="top">'+@requestor+'<br>'+@street+'<br>'+@postcode+' '+@city+' '+@country+'</td></tr>'
  set @mess = @mess + '<tr><td valign="top">Contact on site:</td><td valign="top">'+@contactName+', '+@contactPhone+', '+@contactEmail+'</td></tr>'
  set @mess = @mess + '</table>'
  set @mess = @mess + '<br>'
  set @mess = @mess + '<br>'  
  set @mess = @mess + '<br>'
  set @mess = @mess + '<a href="a2l:\\Link=docg.sm_workorder.'+LTRIM(rtrim(@woGID))+'">PDB Link to '+@woNN+'</a>'
  
  
  /*exec MSG_SEND_TOUSER 3,3,@subj,@mess*/
  
  exec MSG_SEND @UserID, 'support.europe@ipgphotonics.com', null, @subj, @mess
  
  set nocount off

END