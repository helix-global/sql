CREATE procedure [dbo].[PR_NEXT_OPERATION_ALL] @DeviceID int
as 
SET nocount on

delete from PR_DEVICE_SKIPPED_OP where PR_DEVICE_SKIPPED_OP.DEVICEID = @DeviceID

update PR_OPERATION set RERUNALL = 0 where DEVICEID = @DeviceID and RERUNALL = 1 and S_S in (1000013,1000019)

exec PR_NEXT_OPERATION @DeviceID, null

declare @OperID int

declare cur cursor local read_only for 
select A.ID from PR_OPERATION A with (nolock)
 where A.DEVICEID = @DeviceID
   and A.S_S in (1000013,1000019)
   order by A.ID
open cur;
WHILE 1=1
BEGIN
   FETCH NEXT FROM cur INTO @OperID;
   IF @@FETCH_STATUS<>0 BREAK;
   
   exec PR_NEXT_OPERATION @DeviceID, @OperID
   
END
close cur;
deallocate cur;
 
SET nocount off