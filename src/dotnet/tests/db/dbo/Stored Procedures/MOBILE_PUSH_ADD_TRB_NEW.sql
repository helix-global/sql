

CREATE PROCEDURE [dbo].[MOBILE_PUSH_ADD_TRB_NEW] @REQUESTID int
AS
BEGIN

/* KB4439 Add new push message about new transportation booking request for delivery to driver mobile device */

--declare @REQUESTID int = 2

declare @TITLE nvarchar(100) = 'New transportation request!'
declare @BODY nvarchar(MAX);

declare @TOUSERID int
declare @BOOKIDATE varchar(10)
declare @PICKUPTIME varchar (10)
declare @PICKUPLOCATION varchar (MAX)
declare @DESC varchar (MAX)


-- check for filled fields
if ((select A.PICKUPTIME from TRB_REQUESTS A where 	A.ID = @REQUESTID) is null)
begin
	raiserror('#EPickup time must be filled befor senf to driver',16,1)
	return;
end

if ((select A.TERMINTIME from TRB_REQUESTS A where 	A.ID = @REQUESTID) is null)
begin
	raiserror('#ETermin time must be filled befor senf to driver',16,1)
	return;
end

if ((select A.DRIVERUSERID from TRB_REQUESTS A where 	A.ID = @REQUESTID) is null)
begin
	raiserror('#EDriver must be filled befor senf to driver',16,1)
	return;
end


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
	'transportationrequestnew' -- inform about new request ()
	)

END