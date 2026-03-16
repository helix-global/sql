CREATE function [dbo].[PR_DEVICE_WAITTIME](@DeviceID int, @DeviceState int)
returns int 
as
begin
  if @DeviceState not in (1000008,1000029,1000011,1000069) /*in production,pending production,in service,postponed*/
    return null

  declare @maxDate datetime 
  select @maxDate = MAX(A.S_CDT) from dbo.PR_OPERATION A with (nolock, index(IX_PR_OPERATION_1)) 
   where A.DEVICEID = @DeviceID 
     and A.COMPLETED_DT is null
     and A.S_S in (/*1000031,*/1000032) /*in progress, pending*/
     
  if @maxDate is null  
     return null
     
  return datediff(MINUTE,@maxDate,getdate())
end;