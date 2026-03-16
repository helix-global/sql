CREATE procedure [dbo].[PR_CHECK_DEV_SHIPPED0] @DeviceID int, @aMode int
as 
set nocount on

declare @DepID int
select @DepID = B.DEPARTMENTID
from PR_DEVICE A with (nolock) 
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID 
where A.ID = @DeviceID

if exists (select A.ID from SH_SETTINGS A where A.DEPID = @DepID and isnull(A.BLOCKSHMETHOD,0) = 1 )
   and not exists (select B.ID from SH_ORDER_T B where B.DEVICEID = @DeviceID)
  raiserror('Please use "Shipment Request" document to proceed shipment.',16,0)

set nocount off