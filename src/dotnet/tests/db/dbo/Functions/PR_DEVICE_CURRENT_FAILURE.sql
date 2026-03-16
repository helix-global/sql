CREATE function [dbo].[PR_DEVICE_CURRENT_FAILURE](@aDeviceID int,@aDeviceSS int)
returns nvarchar(max) WITH SCHEMABINDING
as
begin
  if @aDeviceSS not in(1000008,1000029,1000011) /*in production,pending production,in service*/
    return null
    
  declare @res nvarchar(max)
  set @res = '';
  
  declare @errCount int
  set @errCount = 0
  
  select @res = @res + A.REPAIRREASON, @errCount = @errCount + 1
  from dbo.PR_OPERATION A with (nolock)
  where A.DEVICEID = @aDeviceID
    and A.S_S in (1000018)


  if @errCount > 1
    set @res = LTRIM(RTRIM(str(@errCount))) + ' failures'
    
  if LEN(LTRIM(@res)) = 0
    return null  
    
  return @res;
end;