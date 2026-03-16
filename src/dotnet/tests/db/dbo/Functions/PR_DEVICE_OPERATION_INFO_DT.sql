create FUNCTION [dbo].[PR_DEVICE_OPERATION_INFO_DT] (@deviceId int, @operTypeId int, @mode int)
returns datetime
as
begin

    declare @ret datetime

 
   select top 1 @ret = A.COMPLETED_DT
   from PR_OPERATION A with (nolock)
   left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
   where B.ID = @deviceId
     and A.OPERTYPEID = @operTypeId
     and A.COMPLETED_DT is not null
   order by A.ID desc
   

    return @ret

end