CREATE function [dbo].[PR_PRORDER_FINEACCESS]( @DocumentID int, @UserID int)
returns nvarchar(max)
as
begin

	declare @PLA_DEPARTMENT int = 170
	declare @PLA_CUSTOMER int = 8
	declare @SPA int = 25

	if dbo.COM_USER_DEPARTMENT(@UserID)<>@PLA_DEPARTMENT or dbo.DEF_USERINGROUP(@UserID,@SPA,getdate())=0 --only PLA and Supervisor Assistant
		return 'NoActionsMarked=IS_HIDDEN_NOT_PLA;'

	if not exists(select ID from PR_PRORDER P where ID=@DocumentID and P.DEPARTMENTID=@PLA_DEPARTMENT and P.CUSTOMERID=@PLA_CUSTOMER) --only from PLA to PLA
		return 'NoActionsMarked=IS_HIDDEN_NOT_PLA;'

	return null
end