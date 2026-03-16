-- =============================================
-- Author:		Maksim Efimov
-- Create date: 20.11.2023
-- Description:	KB4440
-- =============================================
CREATE FUNCTION MOBILE_USERSPUSHTOKENS ()

RETURNS TABLE
--@res TABLE (ID int, DEVICEID varchar(50), PUSHTOKEN varchar(250), OSNAME varchar(50),
--					USERNAME varchar(50), U_LOGINNAME nvarchar(200), U_LOGINNAME2 nvarchar(200), U_FULLNAME nvarchar(200))
AS
RETURN 
(
	select 
		T.ID,
		T.DeviceID DEVICEID,
		T.Token PUSHTOKEN,
		T.OSname OSNAME,
		T.UserName USERNAME,
		U.LOGINNAME U_LOGINNAME,
		U.LOGINNAME2 U_LOGINNAME2,
		U.FULLNAME U_FULLNAME
	from 
		MOBILE_PUSH_TOKENS T with (nolock)
	left join DEF_USERS as U with (nolock) on T.UserID = U.ID
)