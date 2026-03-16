create procedure [dbo].[COM_CONFIRM_EMERG_CASE_SHORT_ABSENCE]  @UserID int, @aMode int
as 
set nocount on

update COM_VACATION set S_S = 1000141/*approved*/ , APP_REJ_DT = getdate(), APP_REJ_USERID = @UserID
where COM_VACATION.S_S = 1000140 /*not approved*/
  and COM_VACATION.EMERG_CASE > 0
  and COM_VACATION.VACATIONTYPE = 30 /*short abs*/
  and COM_VACATION.SUBMIT = 1
  

set nocount off