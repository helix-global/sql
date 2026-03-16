

CREATE PROCEDURE [dbo].[MOBILE_PUSH_ADD_TRB_CANCEL] @REQUESTID int
AS
BEGIN

/* KB4439 Add new push message about new transportation booking request for delivery to driver mobile device */

--declare @REQUESTID int = 2

declare @TITLE nvarchar(100) = 'CANCELED transportation request!'
declare @BODY nvarchar(MAX);

declare @TOUSERID int
declare @BOOKIDATE varchar(10)
declare @PICKUPTIME varchar (10)
declare @PICKUPLOCATION varchar (MAX)
declare @DESC varchar (MAX)


select TOP 1 
	@TOUSERID = DRIVERUSERID,
	@BOOKIDATE = convert(varchar(10), FORMAT(R.BOOKDATE,'dd.MM.yyyy')),
	@PICKUPTIME = convert(varchar(10), FORMAT(R.PICKUPTIME, 'hh:mm' )),
	@PICKUPLOCATION = R.PICKUPLOCATION,
	@DESC = R.DESCRIPTION
from 
	TRB_REQUESTS R with (nolock)
where 
	ID = @REQUESTID


select @TOUSERID, @BOOKIDATE

 
set @BODY = @BOOKIDATE + ' at ' + @PICKUPTIME + ' from ' + @PICKUPLOCATION + ' (' + @DESC + ')'

--select @BODY

insert into dbo.MOBILE_PUSH_MESSAGES (TOUSERID, TITLE, BODY, DOCOID, DOCID, EMPLNAME, PAYLOADCOMMAND)
values(

	@TOUSERID, 
	@TITLE,
	@BODY,
	5130007, --Transportation booking request class
	@REQUESTID,
	(select top 1 FULLNAME from dbo.DEF_USERS with (nolock) where ID = @TOUSERID),
	'transportationrequestcancel' -- inform about new request ()
	)

END