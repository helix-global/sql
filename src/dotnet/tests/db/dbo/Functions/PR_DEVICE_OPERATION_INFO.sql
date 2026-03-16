create FUNCTION [dbo].[PR_DEVICE_OPERATION_INFO] (@deviceId int, @operTypeId int, @mode int)
returns nvarchar(max)
as
begin

    declare @ret nvarchar(max)

 
   select top 1 @ret = C.FULLNAME
   from PR_OPERATION A with (nolock)
   left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
   left join DEF_USERS C with (nolock) on C.ID = A.S_MR
   where B.ID = @deviceId
     and A.OPERTYPEID = @operTypeId
     and A.COMPLETED_DT is not null
   order by A.ID desc
   

    return @ret

end