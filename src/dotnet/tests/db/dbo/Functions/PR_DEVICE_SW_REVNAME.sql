create function [dbo].[PR_DEVICE_SW_REVNAME](@DeviceID int, @ParamID int)
returns nvarchar(200) as 
begin
  
  declare @res nvarchar(200)
  
  select top 1 @res = B.NAME
  from PR_DEVICE_SW A with (nolock)
  left join SW_TOOL_VERSIONS B with (nolock) on B.ID = A.SWVERSIONID
  where A.DEVICEID = @DeviceID
    and A.SWID = @ParamID
  
  return @res;  

end