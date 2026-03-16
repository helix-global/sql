create function [dbo].[PR_DEVICE_BOMITEM_BYNAME_T](@DeviceID int, @BomName nvarchar(100))
returns @res table (PARTID int,PARTSN nvarchar(50),PARTMODELID int,PARTMODELNAME nvarchar(300),PARTMODELCODE nvarchar(50))
begin

  insert into @res (PARTID,PARTSN,PARTMODELID,PARTMODELNAME,PARTMODELCODE)
  select A.ID,A.SN,A.MODELID,B.NAME,B.CODE
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.ID = dbo.PR_DEVICE_BOMITEM_BYNAME(@DeviceID, @BomName)
  
  return 

end