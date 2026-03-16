CREATE procedure [dbo].[PR_CHECK_DEV_SHIPPED] @DeviceID int, @aMode int
as 
set nocount on

declare @DepID int
declare @sn nvarchar(50)
declare @errmess nvarchar(250)

select @DepID = T.DEPARTMENTID
      ,@sn = A.SN
from PR_DEVICE A with (nolock)
left join PR_MODELS M with (nolock) on M.ID = A.MODELID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where A.ID = @DeviceID

if exists (select ID from PR_NAV_DEPMODES A with (nolock) where A.DEPID = @DepID and ISNULL(A.BLOCKSH,0) = 1 and isnull(A.INVENTORYMODE,0) = 0)
begin
  if exists (select * from PDB_BUFFER..MATERIALS A where A.OPERATIONID in (select B.ID from PR_OPERATION B where B.DEVICEID = @DeviceID))
  begin
    set @errmess = '#EComponents buffer not empty. Cannot ship the item '+@sn+'.'
    raiserror(@errmess,16,0);
    set nocount off
    return
  end   
  if exists (select * from PDB_BUFFER..DEVICES A where A.OPERATIONID in (select B.ID from PR_OPERATION B where B.DEVICEID = @DeviceID))
  begin
    set @errmess = '#EItems buffer not empty. Cannot ship the item '+@sn+'.'
    raiserror(@errmess,16,0);
    set nocount off
    return
  end   
end

exec PR_UPDATE_ORDERS @DeviceID, null, null, null

set nocount off