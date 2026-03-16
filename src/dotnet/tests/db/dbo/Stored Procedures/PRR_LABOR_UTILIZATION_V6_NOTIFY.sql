CREATE procedure [dbo].[PRR_LABOR_UTILIZATION_V6_NOTIFY](@RequestID int, @UserID int)
as 
BEGIN
  set nocount on
  
  declare @emplID int
  
  select @emplID = dbo.DEF_EMPLOYEE(A.S_CR) from PRR_LU_REPORT_REQUEST A with(nolock) where A.ID = @RequestID and A.S_S = 2130078/*prepared*/
  
  if @emplID is null
  begin
	set nocount off  
	return  
  end
  
  
  declare @mess nvarchar(max)
  declare @subj nvarchar(1024) = 'Report "Labor Utilization" is ready.'
     
  select @mess = 'Dear '+ coalesce(A.GIVENNAME,A.NAME,'All')
  from COM_EMPLOYEE A with(nolock)
  where A.ID = @emplID
  
  set @mess = @mess + ',<br><br>'
  set @mess = @mess + 'Requested report "Labor Utilization" is ready.<br>'
  set @mess = @mess + 'Please use <a href="a2l:\\Link=doc.prr_lur_request.'+LTRIM(rtrim(str(@RequestID)))+'">this link</a> to open the prepared report.<br><br>'
  set @mess = @mess + 'This e-mail was created automatically. Please do not respond.<br>PDB<br>'
  
  exec MSG_SEND_TOEMPLOYEE @UserID,@emplID,@subj,@mess
     
  set nocount off  
END