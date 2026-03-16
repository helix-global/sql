

--180336

CREATE PROCEDURE [dbo].[MOBILE_PUSH_ADD_INFO_CONFIRMREJECT_VACATION] (@VacationID int)
AS
BEGIN
set nocount on

declare @state int 
declare @resNotifyed datetime
declare @applUserID int
declare @vtype int
declare @vtext nvarchar(max)
declare @applUserMame nvarchar(max)

select @state = A.S_S 
      ,@resNotifyed = A.RESULTNOTYFIED
      ,@applUserID = A.APPLIED_USERID
      ,@vtype = A.VACATIONTYPE
      ,@vtext = dbo.COM_VACATION_TOSTRING(A.ID,0)
	  ,@applUserMame = U.FULLNAME
from COM_VACATION A with (nolock) 
	left join DEF_USERS U with (nolock) on U.ID = A.APPLIED_USERID
where A.ID = @VacationID
	



if (@state = 1000141 or @state = 1000142) and (@vtype = 10 or @vtype = 20 or @vtype = 30)
begin 
insert into MOBILE_PUSH_MESSAGES (TOUSERID, TITLE, BODY, DOCOID, DOCID, EMPLNAME, PAYLOADCOMMAND )
select
	--26052,
	@applUserID, 
	case when @state = 1000141 then 'Absence proposal APPROVED' when @state = 1000142 then 'Absence proposal REJECTED' end,
	case when @state = 1000141 then 'Your ' + @vtext + ' has been approved' when @state = 1000142 then 'Your ' + @vtext + ' has been rejected' end,
	1000184,
	@VacationID,
	@applUserMame,
	case when @state = 1000141 then 'absenceconfirm' when @state = 1000142 then 'absencereject' end
end

set nocount off

END