CREATE procedure [dbo].[PR_UPDATE_PRTIME] @DeviceID int
as 
set nocount on

declare @restProdTime decimal(10,1)
set @restProdTime = dbo.PR_DEVICE_REST_PROD_TIME(@DeviceID)
update PR_DEVICE set PRRESTTIME = @restProdTime where ID = @DeviceID and isnull(PRRESTTIME,0) <> @restProdTime

declare @fullProdTime decimal(10,1)
set @fullProdTime = dbo.PR_DEVICE_FULL_PROD_TIME(@DeviceID)
update PR_DEVICE set PRFULLTIME = @fullProdTime where ID = @DeviceID and isnull(PRFULLTIME,0) <> @fullProdTime

declare @rdns decimal(10,1)
set @rdns = dbo.PR_READINESS(@DeviceID,null)
update PR_DEVICE set STOREDREADINESS = @rdns where ID = @DeviceID and isnull(STOREDREADINESS,0) <> @rdns

set nocount off