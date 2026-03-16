create function [dbo].[PR_PREVIOS_OP_DONE](@DeviceID int ,@OrderID int, @DoneLevel int,@RevOperID int)
returns int
begin
  
  if exists (select A.ID from PR_OPERATION A with (nolock) 
              where A.DEVICEID = @DeviceID
                and A.ORDERID = @OrderID
                and A.OPLEVEL = @DoneLevel
                and A.REVOPERID = @RevOperID
                and A.S_S in (1000013,1000019))
                return 1

  if exists (select A.DEVICEID
               from PR_DEVICE_SKIPPED_OP A
              where A.DEVICEID = @DeviceID
                and A.ORDERID = @OrderID
                and A.OPLEVEL = @DoneLevel
                and A.REVOPERID = @RevOperID
              )
             return 1
  
  return 0
end