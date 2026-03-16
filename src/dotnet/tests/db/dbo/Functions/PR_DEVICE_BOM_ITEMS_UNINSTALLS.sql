CREATE function [dbo].[PR_DEVICE_BOM_ITEMS_UNINSTALLS] (@DeviceID int, @aMode int)
returns @res table (BOMID int, PARTID int, PARTSN nvarchar(50), PARTMODELID int, OPERATIONID int)
as 
begin
/*
@aMode = 1 - не включать снятия по операциям производственного заказа
*/

	insert into @res (BOMID, PARTID, PARTSN, PARTMODELID, OPERATIONID)
	select C.BOMID
	      ,C.PARTID
	      ,D.SN
	      ,D.MODELID
	      ,A.ID
	from PR_OPERATION A with (nolock) 
	left join PR_OPERATION_UNINSTALL B with (nolock) on B.OPERID = A.ID
	left join PR_OPERATION_INSTALL C with (nolock) on C.ID = B.INSTALLROWID
	left join PR_DEVICE D with (nolock) on D.ID = C.PARTID
	left join PR_DEVICE AA with (nolock) on AA.ID = @DeviceID
	where A.ID in (select FF.ID from dbo.PR_DEVICES_OPERATIONS(@DeviceID) FF) 
	  and A.S_S in (1000013,1000019,1000116)
	  and C.ID is not null
	  and (isnull(@aMode,0) <> 1 or A.ORDERID <> AA.ORDERID)

	
    return

end