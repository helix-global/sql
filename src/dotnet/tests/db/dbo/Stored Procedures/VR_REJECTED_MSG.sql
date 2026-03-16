CREATE PROCEDURE[dbo].[VR_REJECTED_MSG](@MethodRemark nvarchar(max), @ContextID int, @UserID int)
as
begin
	/* KB4831 */

	update VR_REQUEST set ACOMMENTS = convert(nvarchar(max), ISNUll(ACOMMENTS,'')) + CHAR(13) + CHAR(10) + convert(nvarchar(15),'Reject reason: ') + @MethodRemark  where ID = @ContextID and @MethodRemark is not null
	
	--declare @reason nvarchar(max) = 
	
	
	declare @modify_by nvarchar(200) = (select dbo.DEF_EMPLOYEE_NAME((select TOP 1 S_MR  from VR_REQUEST where ID = @ContextID)))
	declare @ToUser int
	declare @DocNumber nvarchar(max)

	 select TOP 1 
	 @ToUser = S_CR,
	 @DocNumber = ND
	 from VR_REQUEST where ID = @ContextID
	
	declare @msg nvarchar(max) = 
	'Hello!<br/>' +
	'Visitor request No.'+
	@DocNumber +
	' was rejected <a href="a2l:\\Link=doc.vr_request.' + convert(nvarchar(10),@ContextID) + '">Link in PDB</a> <br/>' + 
	'<br/>' +
	'Please do not respond,<br/>' +
	'Production Database'

	declare @subj nvarchar(max) = 'Your Visitor Request ' + @DocNumber + ' was rejected.'
	
	EXEC MSG_SEND_TOUSER @UserID, @ToUser, @subj, @msg

end