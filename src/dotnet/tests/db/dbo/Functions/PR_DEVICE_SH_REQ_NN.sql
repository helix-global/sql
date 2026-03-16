CREATE function [dbo].[PR_DEVICE_SH_REQ_NN](@aDeviceID int, @aMode int)
returns nvarchar(50) WITH SCHEMABINDING
as
begin

  declare @res nvarchar(50)
  
  select top 1 @res = B.ND
  from dbo.SH_ORDER_T A with (nolock)
  left join dbo.SH_ORDER B with (nolock) on B.ID = A.SHORDERID
  where A.DEVICEID = @aDeviceID
    and B.S_S = 1000024 /*shipped*/
  order by A.ID desc
    
  return @res
end;