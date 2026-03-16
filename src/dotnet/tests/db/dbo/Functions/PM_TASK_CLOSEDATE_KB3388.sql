create function [dbo].[PM_TASK_CLOSEDATE_KB3388](@aTaskID int)
returns datetime
as
begin

/*KB3388 возвращает датувремя которую нужно проставить в Close Date таска по логике KB3388 пункт 1*/

declare @res datetime

select @res = A.COMPLETE_DT from PM_TASK A with(nolock) where A.ID = @aTaskID

if @res is null
begin
  select @res = max(DD) from PM_TASK_TIME A with(nolock) where A.TASKID = @aTaskID
end

if @res is null
  set @res = getdate()

return @res  

end;