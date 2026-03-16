CREATE function [dbo].[PR_DEVICE_MATERIALS_USAGE_TAB] (@DeviceID int, @aMode int)
returns @res table (CODE nvarchar(50),QTY decimal(18,6))
as 
begin


	insert into @res (CODE,QTY)
	select B.CODE
	  ,isnull(A.PREP_RESULT,1) * B.QUANTITY as QTY
	from PR_OPERATION A with (nolock) 
	left join PR_OPERATION_MU B with (nolock) on B.OPERID = A.ID
	where A.ID in (select FF.ID from dbo.PR_DEVICES_OPERATIONS(@DeviceID) FF) 
	  and A.S_S in (1000013,1000019,1000116)
	  and B.ID is not null

	
    return

end