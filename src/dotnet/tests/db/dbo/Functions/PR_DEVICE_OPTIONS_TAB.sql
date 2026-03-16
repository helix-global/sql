CREATE function [dbo].[PR_DEVICE_OPTIONS_TAB] (@DeviceID int)
returns @res table (OPTID int,BOMID int,MODELID int,SN nvarchar(50),PARTID int,QTY int,N int,BOMNAME nvarchar(100),NFROM int)
as 
begin

insert into @res (OPTID,BOMID,QTY,N,BOMNAME)
select A.OPTID,C.SNBOMID,1,B.N,D.NAME
from PR_DEVICE_OPT A with (nolock)
left join COM_NUMBER B with (nolock) on B.N > 0 and B.N <= A.QUANTITY
left join PR_MODELTYPE_OPTIONS C with (nolock) on C.ID = A.OPTID
left join PR_MODELTYPE_BOM D with (nolock) on D.ID = C.SNBOMID
where A.DEVICEID = @DeviceID

declare @mtID int
select @mtID = B.TYPEID
from PR_DEVICE A with (nolock)
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
where A.ID = @DeviceID

update @res set NFROM = dbo.PR_OPTIONBOM_N_FROMNAME(BOMNAME) where N > 1
update @res set BOMNAME = dbo.PR_OPTIONBOM_NAME_FROM_N(BOMNAME,N,isnull(NFROM,1)) where N > 1

/*update @res set BOMNAME = replace(BOMNAME,'1',ltrim(rtrim(str(N)))) where N > 1 */

update @res set BOMID = (select B.ID 
                           from PR_MODELTYPE_BOM B with (nolock) 
                          where B.MTID = @mtID
                            and upper(B.NAME) = upper("@res".BOMNAME))
where N > 1
  
update @res set PARTID = (select top 1 B.PARTID from PR_DEVICE_BOM B with (nolock) where B.DEVICEID = @DeviceID and B.BOMID = "@res".BOMID and B.UNINSTALLOPERID is null order by ID desc)

update @res set SN = (select B.SN from PR_DEVICE B with (nolock) where B.ID = "@res".PARTID)

update @res set MODELID = (select B.MODELID from PR_DEVICE B with (nolock) where B.ID = "@res".PARTID)
  
return

end