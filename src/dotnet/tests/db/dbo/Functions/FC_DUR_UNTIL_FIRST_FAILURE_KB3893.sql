create function [dbo].[FC_DUR_UNTIL_FIRST_FAILURE_KB3893](@aDeviceID int, @aMode int)
returns int
as
begin
/*
duration until first failure по изделию
алгоритм в комментарии к KB3893
*/

declare @res int

declare @fDate datetime

select top 1 @fDate = isnull(A.FAILUREDATE,A.USER3DT)
from FC_REPORT A with(nolock)
where A.DEVICEID = @aDeviceID
order by A.ID 
     
if @fDate is null
begin
	select top 1 @fDate = A.INC_DATE
	from PR_PRORDER_SERVICE A with(nolock)
	where A.DEVICEID = @aDeviceID
	order by A.ID
end
     
if @fDate is not null     
begin
	
	select @res = datediff(day,A.COMPLETED_DT,@fDate)
	from PR_DEVICE A with(nolock)
	where A.ID = @aDeviceID
	
	if @res < 0
	  set @res = 0

end
     
return @res  

end;