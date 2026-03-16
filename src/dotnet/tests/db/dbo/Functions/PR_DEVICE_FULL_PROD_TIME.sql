create function [dbo].[PR_DEVICE_FULL_PROD_TIME](@DeviceID int)
returns decimal(10,1) as 
begin

declare @result decimal(10,1)

select @result = MAX(A.FROMBEGIN_TIME) from dbo.PR_DEVICE_REST_PROD_TIME_T(@DeviceID) A
where A.DONE in (0,1) /* выкидываются только пропущенные (2)*/

return @result

end