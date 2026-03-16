CREATE FUNCTION [dbo].[PR_DEVICE_PLANNED_DATE]
(
	@deviceId int
)
RETURNS datetime
AS
BEGIN
	declare @d datetime
	
	SELECT @d = coalesce(T1002800.CDD,T1000870.CDD,T1000225.CDD)
		from PR_DEVICE A with (nolock) 
			left join PR_PRORDER T1000225 with (nolock) on T1000225.ID = A.ORDERID
			left join PR_SUPPLY T1000870 with (nolock) on T1000870.ID = A.SORDERID
			left join PR_PRORDER T1002800 with (nolock) on T1002800.ID = A.LASTSRVORDID
			
	RETURN @d

END