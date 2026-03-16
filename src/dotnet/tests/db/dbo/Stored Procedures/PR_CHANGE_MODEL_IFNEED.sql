CREATE procedure [dbo].[PR_CHANGE_MODEL_IFNEED]  @OperationID int
as 
set nocount on

declare @DeviceID int

declare @NewModelID int
declare @OldModelID int
declare @DeviceModelID int
declare @state int

declare @nowMTID int
declare @newMTID int

select 
 @state = A.S_S
,@DeviceID = A.DEVICEID 
,@NewModelID = A.NEWMODELID
,@OldModelID = A.OLDMODELID
,@DeviceModelID = D.MODELID
,@nowMTID = MNOW.TYPEID
,@newMTID = MNEW.TYPEID
from PR_OPERATION A with (nolock)
left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
left join PR_MODELS MNOW with (nolock) on MNOW.ID = D.MODELID
left join PR_MODELS MNEW with (nolock) on MNEW.ID = A.NEWMODELID
where A.ID = @OperationID

if @NewModelID is null
begin
  set nocount off
  return
end

if (@state in (1000013,1000019) and @DeviceModelID <> @NewModelID) 
begin
  
  if (@nowMTID <> @newMTID)
    raiserror('Cannot change device model to different model type.',16,1);

  update PR_OPERATION set OLDMODELID = @DeviceModelID where ID = @OperationID
  update PR_DEVICE set MODELID = @NewModelID where ID = @DeviceID
  exec PR_DEVICE_CHECK_FAR_MODEL @DeviceID

end
else if (@state not in (1000013,1000019) and @DeviceModelID <> @OldModelID and @DeviceModelID = @NewModelID) 
begin
  
  update PR_DEVICE set MODELID = @OldModelID where ID = @DeviceID
  exec PR_DEVICE_CHECK_FAR_MODEL @DeviceID
  
end

set nocount off