CREATE function [dbo].[PR_DEVICE_PARAMS_VALUES_EXISTS] (@aDeviceID int,@aMode int)
returns  table 
as 
return
/* 
  функция возвращает ID параметров (с типом Value) которые имеют значения для @aDeviceID 
  
  позволяет быстрее выводить списки значений параметров по изделиям отбрасывая параметры не имеющие значения еще до вызова dbo.PR_DEVICE_PARAMS 

  ? учитывать ли default values здесь
  
*/
(
select A.PARAMID as ID
from PR_OPERATION_PARAMS A with (nolock)
left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
where B.DEVICEID = @aDeviceID
union
select N.PARAMID as ID
from PR_DEVICE_IN_VALUES N with (nolock)
where N.DEVICEID = @aDeviceID
union
select A.PARAMID as ID
from PR_OPERATION_PARAMS A with (nolock)
left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
where A.OPERID in (select N.OPERID from PR_PARENT_OPERATION N where N.DEVICEID = @aDeviceID and isnull(N.DONTUSEPARAMETERS,0) <> 1)

)