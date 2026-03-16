create function [dbo].[PR_OPERS_USED_IN_DEVICE_PROD] (@DeviceID int)
returns @res table (ID int)
as 
begin
/* используется во view подбора форм операций, которые были выполнены во время производства */

  insert into @res (ID)
  select distinct A.OPERTYPEID
  from PR_OPERATION A with (nolock)
  left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
  where A.DEVICEID = @DeviceID
    and A.COMPLETED_DT is not null
    and exists (select C.ID from PR_MAP_OPER C where C.MAPID = B.MAPID and C.OPERID = A.OPERTYPEID)

return


end