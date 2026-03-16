CREATE function [dbo].[PR_DEVICE_REST_PROD_TIME](@DeviceID int)
returns decimal(10,1) as 
begin

declare @result decimal(10,1)
declare @qty int

select @result = MAX(A.FROMEND_TIME) from dbo.PR_DEVICE_REST_PROD_TIME_T(@DeviceID) A
where A.DONE = 0


/*KB4624*/

select @qty = ISNULL(A.RESQUANTITY,1) from PR_DEVICE A with(nolock) where A.ID = @DeviceID
if @qty > 1
  set @result = @result * @qty


return @result

end