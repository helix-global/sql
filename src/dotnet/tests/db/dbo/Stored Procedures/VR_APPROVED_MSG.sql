CREATE PROCEDURE[dbo].[VR_APPROVED_MSG](@aVR_ID int,@aUserID int)
as
begin

	/* KB4831 */
	/* +KB4895 29.07.2024 Efimov - fix email addresses depending building addresses in request  + add this e-mails as CC in e-mail */
	/* +KB4905 09.08.2024 Efimov - p.9 - send notification about approve to delivery list */

	--declare @UserID int = 26052
	--declare @ContextID int = 3

	
	
	/* msg to requester */
	-- requester user
	declare @ToUser int
	declare @DocNumber nvarchar(max)
	declare @DepID int

	 select TOP 1 
	 @ToUser = S_CR,
	 @DocNumber = ND,
	 @DepID = DEPID
	 from VR_REQUEST where ID = @aVR_ID

	 declare @subj nvarchar(max) = 'Your Visitor Request ' + @DocNumber + ' was approved.'
	 -- msg
	declare @msg nvarchar(max) = 
	'Hello!<br/>' +
	'Visitor request No.'  + @DocNumber + ' was approved <a href="a2l:\\Link=doc.vr_request.' + convert(nvarchar(10),@aVR_ID) + '">Link in PDB</a> <br/>' + 
	'<br/>' +
	'Please do not respond,<br/>' +
	'Production Database'


	
	
	/* get emails depending on building in address (for CC email)*/
	declare @emails nvarchar(max) = ''
	declare @buildings nvarchar(max) = (select top 1 VISITOR_ADDRESSES from VR_REQUEST where ID = @aVR_ID)
	
	if(@buildings like '%D9%')
		set @emails = @emails + 'ipgl-training@ipgphotonics.com;'

	if (@buildings like '%D12_%')
		set @emails = @emails + 'ipgl-internal-sales@ipgphotonics.com;'

	/* KB5309 */
	if (@buildings like '%K1%')
		set @emails = @emails + 'IPGL-LA-Admin@ipgphotonics.com;'
		 
	
	if (@buildings not like '%D9%'
		and @buildings not like '%D12_%' 
		and @buildings not like '%K1%')
		set @emails = @emails + 'ipgl-secretary@ipgphotonics.com;'
	
	--send message to requestor and copy to group depending building
	EXEC MSG_SEND_TOUSER_WITHCOPY @aUserID, @ToUser, @emails, @subj, @msg


	/* KB4905 */
	EXEC MSG_SEND_TODELIVERYGROUP @aUserID, 2510, @DepID, @subj, @msg 


end