CREATE function [dbo].[PR_OPER_REPEATED](@aOperID int,@aDeviceID int,@aOrderID int,@aOperType int)
returns int
as
begin
  if exists (select A.ID from PR_OPERATION A with (nolock, index([IX_PR_OPERATION_1])) 
              where A.DEVICEID = @aDeviceID 
                /*and A.ORDERID = @aOrderID*/
                and A.OPERTYPEID = @aOperType
                and A.S_S <> 1000023 /*canceled*/
                and A.ID < @aOperID)
     return 1;
                     
  return null;
end;