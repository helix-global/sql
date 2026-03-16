--KB4778:2024-05-15: Added color in the keywords of the message.
CREATE PROCEDURE [dbo].[COM_VACATION_RESULT] (@VacationID int, @aUserID int)
AS
BEGIN
set nocount on

declare @state int 
declare @resNotifyed datetime
declare @applUserID int
declare @vtype int
declare @vtext nvarchar(max)

select @state = A.S_S 
      ,@resNotifyed = A.RESULTNOTYFIED
      ,@applUserID = A.APPLIED_USERID
      ,@vtype = A.VACATIONTYPE
      ,@vtext = dbo.COM_VACATION_TOSTRING(A.ID,2)
  from COM_VACATION A with (nolock) where A.ID = @VacationID

if @vtype in (10,30)
begin
  if @state = 1000141 and @resNotifyed is null and @applUserID is not null
  begin
    set @vtext = '<p style="font-family: Arial, Helvetica, sans-serif;font-size: smaller;">Your absence proposal:<br>'+@vtext+'<br>has been <span style="color: green">approved</span>.<br><br>Please do not reply,<br>PDB</p>'
    exec MSG_SEND_TOUSER @aUserID, @applUserID, 'Your absence proposal has been approved.', @vtext
    update COM_VACATION set RESULTNOTYFIED = getdate() where ID = @VacationID
  end
  else if @state = 1000142 and @resNotifyed is null and @applUserID is not null
  begin
    set @vtext = '<p style="font-family: Arial, Helvetica, sans-serif;font-size: smaller;">Your absence proposal:<br>'+@vtext+'<br>has been <span style="color: red">rejected</span>.<br><br>Please do not reply,<br>PDB</p>'
    exec MSG_SEND_TOUSER @aUserID, @applUserID, 'Your absence proposal has been rejected.', @vtext
    update COM_VACATION set RESULTNOTYFIED = getdate() where ID = @VacationID
  end
end

/* inform mobile app users that Absence proposals request state change (Approved or declined) */
exec MOBILE_PUSH_ADD_INFO_CONFIRMREJECT_VACATION @VacationID

set nocount off
END