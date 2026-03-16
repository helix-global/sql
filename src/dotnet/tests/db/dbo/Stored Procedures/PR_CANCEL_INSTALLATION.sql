create procedure [dbo].[PR_CANCEL_INSTALLATION] @DeviceID int, @OrderID int
as 
set nocount on
/*находит компоненты по отмененным опеациям (1000023 canceled) и проставляет им статус uninstalled*/

update PR_DEVICE set S_S = 1000081 /*uninstalled*/
where ID in (
select C.ID
from PR_OPERATION A with (nolock)
left join PR_OPERATION_INSTALL B with (nolock) on B.OPERID = A.ID
left join PR_DEVICE C with (nolock) on C.ID = B.PARTID
where A.DEVICEID = @DeviceID
  and A.ORDERID = @OrderID
  and A.S_S = 1000023 /*canceled*/
  and C.S_S = 1000077 /*installed*/
)

set nocount off