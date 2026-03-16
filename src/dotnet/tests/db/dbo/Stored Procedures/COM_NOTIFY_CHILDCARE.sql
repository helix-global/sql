CREATE PROCEDURE [dbo].[COM_NOTIFY_CHILDCARE] (@ID int, @aUserID int, @mode int)
AS
BEGIN
set nocount on

declare @absType int
declare @depID int
declare @emplName nvarchar(50)
declare @period nvarchar(max)
declare @txt nvarchar(max)
declare @remark nvarchar(max)
declare @emplID int

select @absType = A.VACATIONTYPE
      ,@depID = B.DEPID
      ,@emplName = B.NAME
      ,@period = dbo.COM_VACATION_PERIOD_STR(A.ID,0)
      ,@txt = dbo.COM_VACATION_TOSTRING(A.ID,11)
      ,@remark = cast(A.REMARK as nvarchar(max))
      ,@emplID = B.ID
from COM_VACATION A with (nolock)
left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
where A.ID = @ID

declare @subj nvarchar(1024)
declare @mess nvarchar(max) 

if @absType <> 100 /*child care*/
begin
  set nocount off
  return
end

set @subj = 'New absence proposal (Child Care) for '+@emplName+'. Period: '+@period 

set @mess = 'Employee: '+@emplName+'<br>'
set @mess = @mess + @txt
if @remark is not null
	set @mess = @mess + '<br>' + @remark

set @mess = @mess + '<br><br><a href = "a2l:\\Link=doc.com_vacation.'+LTRIM(rtrim(str(@ID)))+'">Link in PDB<a>'
	
set @mess = @mess + '<br><br>Please do not respond,<br>Production Database'

declare @notyID int = 1305 /* Delivery group  "Child Care Notifications About New "Child Care" Absence Proposals"*/
  
	/*
    declare @depHeadSettingCode int
  
	select top 1 @depHeadSettingCode = G.CODE 
	from COM_DH_VP_SETTINGS_T F with (nolock) 
	left join COM_DH_VP_SETTINGS G with (nolock) on G.ID = F.VNESHID
	where F.EMPLID = @emplID

	
	if @depHeadSettingCode = 1 /*production*/
	begin
	  set @notyID = 1311
	  set @depID = 283 /*IPGL*/
	end  
	if @depHeadSettingCode = 2
	begin
	  set @notyID = 1310
	  set @depID = 283 /*IPGL*/
	end  
    */

exec MSG_SEND_TODELIVERYGROUP @aUserID, @notyID, @depID, @subj, @mess 

/*exec MSG_SEND @aUserID, 'dnorkin@ipgphotonics.com', null, @subj, @mess*/
  
set nocount off
END