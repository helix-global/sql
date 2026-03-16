CREATE function [dbo].[PR_DEVICE_CURRENTOPER_tempipm](@aDeviceID int,@aDeviceSS int)
returns nvarchar(max) WITH SCHEMABINDING
as
begin
  return (
           CASE WHEN @aDeviceSS not in(1000008,1000029,1000011,1000069) /*in production,pending production,in service,postponed*/ THEN NULL
                ELSE STUFF((
                              select [text()] = ', ' + B.NAME
                              from dbo.PR_OPERATION A 
                              left join dbo.PR_OPERATIONS B on B.ID = A.OPERTYPEID
                              where A.DEVICEID = @aDeviceID
                                and A.S_S in (1000032,1000033)
                              for xml path('')
                           ), 1, 2, '')
           END
         )
end