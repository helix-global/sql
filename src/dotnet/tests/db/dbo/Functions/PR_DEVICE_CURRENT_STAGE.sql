--KB5427:2025-07-09: Refactoring.
CREATE function [dbo].[PR_DEVICE_CURRENT_STAGE](@DeviceID int,@OrderID int,@DeviceSS int)
returns int
as
begin
  if @DeviceSS not in(1000008,1000029) /*in production,pending production*/
  begin
    return null
  end

  declare @RetVal int
  select top 1
    @RetVal = [opF].[STAGEID]
  from [dbo].[PR_OPERATION] [opr] with(nolock)
    left join [dbo].[PR_OPERATIONS] [opF] with(nolock) on [opF].[ID]=[opr].[OPERTYPEID]
  where [opr].[DEVICEID] = @DeviceID
    and [opr].[ORDERID] = @OrderID
    and [opr].[COMPLETED_DT] is null
  order by [opr].[ID] desc

  return @RetVal;
end;