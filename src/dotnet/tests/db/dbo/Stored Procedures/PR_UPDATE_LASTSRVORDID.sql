CREATE procedure [dbo].[PR_UPDATE_LASTSRVORDID] @aServOrderID int
as 
set nocount on

update PR_DEVICE set LASTSRVORDID = (select top 1 D.ORDERID from PR_PRORDER_SERVICE D where D.DEVICEID = PR_DEVICE.ID order by D.ORDERID desc)
where PR_DEVICE.ID in (select distinct D.DEVICEID from PR_PRORDER_SERVICE D where D.ORDERID = @aServOrderID)
  and isnull(PR_DEVICE.LASTSRVORDID,-546) <> (select top 1 D.ORDERID from PR_PRORDER_SERVICE D where D.DEVICEID = PR_DEVICE.ID order by D.ORDERID desc)

set nocount off