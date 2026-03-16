CREATE function [dbo].[PR_DEVICE_CURRENTOPER](@aDeviceID int,@aDeviceSS int)
returns nvarchar(max) WITH SCHEMABINDING
as
begin
  if @aDeviceSS not in(1000008,1000029,1000011,1000069) /*in production,pending production,in service,postponed*/
    return null
  declare @res nvarchar(max)
  set @res = '';
  select @res = @res + B.NAME + ', '
  from dbo.PR_OPERATION A with (nolock)
  left join dbo.PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
  where A.DEVICEID = @aDeviceID
    and A.S_S in (1000032,1000033)
    
  declare @reslen int
  set @reslen = len(@res)
  if @reslen > 2
    set @res = SUBSTRING(@res,1,@reslen-1)
    
  if LEN(LTRIM(@res)) = 0
    return null  
    
  return @res;
end;