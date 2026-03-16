

CREATE PROCEDURE [dbo].[MOBILE_PUSH_ADD_TRB_CHANGED] @REQUESTID int
AS
BEGIN

/* KB4439 добавление PUSH сообщения об изменении в заявке на транспортировку */


--declare @REQUESTID int = 21 -- test


declare @driverID int = (select top 1 DRIVERUSERID from TRB_REQUESTS where ID = @REQUESTID)

declare @bookDate varchar(20) = (select top 1 FORMAT(BOOKDATE,'dd.MM.yyyy') from TRB_REQUESTS where ID = @REQUESTID)
declare @subj varchar(50) =  @bookDate + ' transportation changed!'
declare @msg varchar(MAX) = 'Changes in: '

select 
	@msg = @msg + dbo.GROUP_CONCAT_D(
	distinct
	case 
		when FIELDNAME = 'BOOKDATE' then 'Booking date' 
		when FIELDNAME = 'DESCRIPTION' then 'Description'
		when FIELDNAME = 'PERSON_VEHICLE' then 'Person/Vehicle'
		when FIELDNAME = 'PICKUPTIME' then 'Pick-up time'
		when FIELDNAME = 'TERMINTIME' then 'Appointment time'
		when FIELDNAME = 'PICKUPLOCATION' then 'Pick-up location'
		when FIELDNAME = 'DRIVERUSERID' then 'Driver'
		when FIELDNAME = 'REMARKS' then 'Remarks/Notes'
		when FIELDNAME = 'CONTACTPERSON' then 'Contact person'
		else FIELDNAME
	end
	--+ ' from "'+ REPLACE(REPLACE(convert(varchar(max),OLDVALUE),CHAR(10),''),CHAR(13),'') +'"'
	--+ ' to "'+ REPLACE(REPLACE(convert(varchar(max),NEWVALUE),CHAR(10),''),CHAR(13),'') +'"'
	--+ CHAR(13)
	,', ')
from 
	TRB_REQUESTS_CHANGES
where 
	VNESHID = @REQUESTID
	and 
	S_S = 5130009



--print @msg; return

insert into dbo.MOBILE_PUSH_MESSAGES (TOUSERID, TITLE, BODY, DOCOID, DOCID, EMPLNAME, PAYLOADCOMMAND)
values(
	@driverID, 
	@subj,
	@msg,
	--5130008, --Transportation booking request changes class
	5130007, -- Transportation booking request
	@REQUESTID,
	(select top 1 FULLNAME from dbo.DEF_USERS with (nolock) where ID = @driverID),
	'transportationrequestchange' -- inform about new request ()
	)


/* if was changed driver? also send this info to previous driver */
-- get old driver userID
set @driverID = (select top 1 OLDVALUE from TRB_REQUESTS_CHANGES where VNESHID = @REQUESTID and S_S = 5130009 and FIELDNAME = 'DRIVERUSERID' order by ID desc)
--repeat send SMS to old driver
if(@driverID is not null)
begin
	insert into dbo.MOBILE_PUSH_MESSAGES (TOUSERID, TITLE, BODY, DOCOID, DOCID, EMPLNAME, PAYLOADCOMMAND)
	values(
		@driverID, 
		@subj,
		@msg + ' (Sie sind nicht mehr der Fahrer für diesen Auftrag)', --you are no longer the driver on this order
		--5130008, --Transportation booking request changes class
		5130007, -- Transportation booking request
		@REQUESTID,
		(select top 1 FULLNAME from dbo.DEF_USERS with (nolock) where ID = @driverID),
		'transportationrequestchange' -- inform about new request ()
		)
end

	--select top 1 FORMAT(BOOKDATE,'dd.MM.yyyy') from TRB_REQUESTS where ID =2





END