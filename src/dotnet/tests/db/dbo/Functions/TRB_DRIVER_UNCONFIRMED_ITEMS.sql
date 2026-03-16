
CREATE FUNCTION dbo.TRB_DRIVER_UNCONFIRMED_ITEMS (@UserID int)
returns int
AS
BEGIN

/* KB4439 - количество неподтвержденных новых заявок + изменений по заявкам для водителя */	
	
declare @res int = null

select  
	@res = COUNT(*)
from 
	dbo.TRB_REQUESTS R with(nolock)
where
	R.DRIVERUSERID = @UserID
	and 
	R.DRIVERCONFIRMCHANGES = 0

/* 

	--for unconfirmed changes count (по изменениям)

select 
	* 
from 
	TRB_REQUESTS_CHANGES C with(nolock)
	join dbo.TRB_REQUESTS R with(nolock) on R.ID = C.VNESHID
where
	R.DRIVERUSERID = @UserID
	and 
	R.DRIVERCONFIRMCHANGES = 0
	and
	isnull(C.DRIVERVIEWED,0) = 0
*/


return @res


END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[TRB_DRIVER_UNCONFIRMED_ITEMS] TO [EMEA\DEXHZ]
    AS [dbo];

