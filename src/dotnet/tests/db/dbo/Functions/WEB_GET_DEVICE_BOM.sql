CREATE function [dbo].[WEB_GET_DEVICE_BOM](@UserID int, @aDeviceID int )
returns table 
return 
select  
	 A.BOMID
	,A.PARTMODELID
	,B.NAME as BOMITEMNAME
	,PM.NAME as PARTMODELNAME
	,PM.CODE as PARTMODELCODE	
	,PT.NAME as PARTMODELTYPENAME
	,A.QTY
from PR_DEVICE AA
cross apply dbo.PR_DEVICE_BOM_MODELS(AA.ID) A
left join PR_MODELTYPE_BOM B with (nolock) on B.ID = A.BOMID
left join PR_MODELS PM with (nolock) on PM.ID = A.PARTMODELID
left join PR_MODELTYPE PT with (nolock) on PT.ID = PM.TYPEID
where AA.ID = @aDeviceID