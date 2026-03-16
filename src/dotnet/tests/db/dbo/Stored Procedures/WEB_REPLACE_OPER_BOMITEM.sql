CREATE procedure [dbo].[WEB_REPLACE_OPER_BOMITEM] @UserID int, @OperID int, @BomName nvarchar(300), @PN nvarchar(20), @SN nvarchar(50), @BatchN nvarchar(100), @Qty decimal(20,10), @Reason int, @ReasonStr nvarchar(250)
as 

set nocount on
declare @err nvarchar(max)
  
declare @MtID int
declare @ss int
declare @checkID int
declare @DeviceID int
declare @RevID int

select @MtID = C.TYPEID
      ,@ss = A.S_S 
      ,@checkID = A.ID
      ,@DeviceID=B.ID
      ,@RevID=B.REVID
from PR_OPERATION A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_MODELS C with (nolock) on C.ID = B.MODELID
where A.ID = @OperID

if @checkID is null
begin
  raiserror('Operation not found.',16,1)
  set nocount off
  return
end

if @ss <> 1000031 /*inprogress*/
begin
  raiserror('Operation cannot be changed out of the "In Progress" state.',16,1)
  set nocount off
  return
end

declare @BomID int

select @BomID = A.ID
from PR_MODELTYPE_BOM A with (nolock)
where A.MTID = @MtID
  and A.NAME = @BomName
  
if @BomID is null
begin
  set @err = 'BOM Item "'+@Bomname+'" not found by item in operation '+str(@OperID)+'.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

declare @PartModelID int
select @PartModelID = A.ID from PR_MODELS A with (nolock) where A.CODE = @PN

if @PartModelID is null
begin
  set @err = 'Part number "'+@PN+'" not found.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

if (@PartModelID not in (select PARTMODELID from dbo.PR_REVISION_BOM_MODELS(@RevID) where BOMID=@BomID))
begin
  set @err = 'Part number "'+@PN+'" is not compatible with current Bom position.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

declare @ComponentId int
select @ComponentId = A.ID from PR_DEVICE A with (nolock) where A.MODELID = @PartModelID and SN=@SN

if @ComponentId is null
begin
  set @err = 'Device with PN "'+@PN+'" and SN "'+@SN+'" not found.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

declare @InstallRowId int
declare @InstalledComponentId int
select @InstallRowId = I.ID 
      ,@InstalledComponentId = I.PARTID
from PR_DEVICE_BOM B with (nolock)
left join PR_OPERATION_INSTALL I with (nolock) on I.OPERID=B.OPERATIONID
where B.DEVICEID=@DeviceID
  and B.BOMID=@BomID
  and I.BOMID=@BomID
  and B.UNINSTALLOPERID is null

if (@InstalledComponentId = @ComponentId)
begin
  set @err = 'Component with SN "'+@SN+'" is already installed to this Bom.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

if exists (select ID from PR_OPERATION_UNINSTALL where INSTALLROWID=@InstallRowId and OPERID=@OperID)
begin
  set @err = 'Component with SN "'+@SN+'" is already installed to this Bom.' 
  raiserror(@err,16,1)
  set nocount off
  return
end

if (@InstallRowId is not null)
begin
  insert into PR_OPERATION_UNINSTALL (GID, S_CR, S_CDT, OPERID, INSTALLROWID, UNITEMSTAT, UNITEMREMARK)
  values (newid(), @UserID, getdate(), @OperID, @InstallRowId, @Reason, @ReasonStr)
end

insert into PR_OPERATION_INSTALL (GID,S_CR,S_CDT,OPERID,BOMID,PARTMODELID,PARTQUANTITY,PARTID,BATCHN,SN)
values (newid(),@UserID,getdate(),@OperID,@BomID,@PartModelID,@Qty,@ComponentId,@BatchN,@SN)

set nocount off