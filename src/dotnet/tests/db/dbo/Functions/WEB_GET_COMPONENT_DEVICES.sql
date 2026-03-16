create function [dbo].[WEB_GET_COMPONENT_DEVICES](@UserID int, @aDeviceID int, @aBOMItemNameMask nvarchar(max))
returns @res table (ID int, PN nvarchar(16), SN nvarchar(50), QTY decimal(20,10), BOMNAME nvarchar(100), DEVICEID int, MODELID int )
as 
begin

  insert into @res (ID,PN,SN,QTY,BOMNAME,DEVICEID,MODELID)
  select A.ID,C.CODE,D.SN,isnull(A.PARTQUANTITY,1),B.NAME,A.DEVICEID,D.MODELID
  from PR_DEVICE_BOM A with (nolock)
  left join PR_MODELTYPE_BOM B with (nolock) on B.ID = A.BOMID
  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
  left join PR_MODELS C with (nolock) on C.ID = D.MODELID
  where A.PARTID = @aDeviceID
    and B.NAME like @aBOMItemNameMask
    and A.UNINSTALLOPERID is null


return

end