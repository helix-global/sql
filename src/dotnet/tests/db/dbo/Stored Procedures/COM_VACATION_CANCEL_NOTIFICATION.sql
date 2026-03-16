CREATE PROCEDURE [dbo].[COM_VACATION_CANCEL_NOTIFICATION] @DocID int, @UserID int, @aMode int
AS
BEGIN
  set nocount on

  declare @now datetime
  set @now = GETDATE()
  
  declare @checkID int
  declare @emplName nvarchar(150)
  declare @emplDep nvarchar(50)   
  declare @emplID int
  declare @vacationDesc nvarchar(max)
  declare @depID int
    
  select @checkID = A.ID
   ,@emplName = C.NAME
   ,@emplDep = D.CODE
   ,@vacationDesc = dbo.COM_VACATION_TOSTRING(B.ID,2)
   ,@emplID = C.ID
   ,@depID = D.ID
  from COM_VACATION_CANCEL A
  left join COM_VACATION B with (nolock) on B.ID = A.VACATIONID
  left join COM_EMPLOYEE C with (nolock) on C.ID = B.EMPLID
  left join COM_DEPARTMENTS D with (nolock) on D.ID = C.DEPID
  where A.ID = @DocID
    and A.S_S = 1000159 /*approval required*/
  
  if @checkID is null
  begin
     set nocount off
     return
  end
  
  declare @msgBody nvarchar(max)
  
  select @msgBody = 'Dear All,<br><br>'
  select @msgBody = @msgBody + 'Cancellation by following absence proposal requires approval:<br><br>'
  select @msgBody = @msgBody + 'Employee: <b>'+isnull(@emplName,'NA')+'</b><br>'
  select @msgBody = @msgBody + 'Department: <b>'+isnull(@emplDep,'NA')+'</b><br>'
  select @msgBody = @msgBody + 'Absence: <b>'+isnull(@vacationDesc,'NA')+'</b><br><br>'
    
  select @msgBody = @msgBody + '<a href = "a2l:\\Link=doc.com_vacation_cancel.'+LTRIM(rtrim(str(@checkID)))+'">Link in PDB<a>'    

  select @msgBody = @msgBody + '<br><br>Please do not reply.<br>Production Database'
  
  declare @notyID int = 1400
  declare @depHeadSettingCode int
  declare @depHeadSettingDepID int
  
	select top 1 @depHeadSettingCode = G.CODE 
	,@depHeadSettingDepID = HH.DEPID	
	from COM_DH_VP_SETTINGS_T F with (nolock) 
	left join COM_DH_VP_SETTINGS G with (nolock) on G.ID = F.VNESHID
	left join COM_EMPLOYEE HH with(nolock) on HH.ID = G.DEFAULT4EMPLID
	where F.EMPLID = @emplID

	if @depHeadSettingCode = 1  /*production*/
	begin
	  set @notyID = 1402
	  set @depID = 283 /*IPGL*/
	end  
	if @depHeadSettingCode = 2
	begin
	  set @notyID = 1401
	  set @depID = 283 /*IPGL*/
	end  
	if @depHeadSettingCode > 2  /*KB4646*/
	begin
	  set @notyID = 1403
	  set @depID = @depHeadSettingDepID
	end  
	
  
  
  exec MSG_SEND_TODELIVERYGROUP @UserID, @notyID, @depID, 'Notification about absence proposal cancelation', @msgBody
    

  set nocount off
    
END