CREATE procedure [dbo].[PR_DEVICE_CHECK_FAR_MODEL] 
  @DeviceID int
as 
set nocount on

  declare @modelid int
  select @modelid = A.MODELID from PR_DEVICE A with (nolock) where A.ID = @DeviceID

  update FC_REPORT set MODELID = @modelid where DEVICEID = @DeviceID and MODELID <> @modelid

set nocount off