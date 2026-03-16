create function [dbo].[FC_FARS_BY_DEVICES] (@deviceIDs nvarchar(max))
returns @res table (ID int)
as 
begin
/*выдает список ID FAR по ID изделий
создано для KB4555
учитывает что в FAR не всегда есть значение DEVICEID 
*/

declare @t table (ID int,SN nvarchar(50),MODELID int)  

insert into @t (ID,SN,MODELID)
select A.ID,A.SN,A.MODELID
from PR_DEVICE A with(nolock)
where A.ID in (select ID from dbo.COM_STR2TABLE_INT(@deviceIDs))


insert into @res (ID) 
select A.ID from FC_REPORT A with(nolock) 
where A.DEVICEID in (select ID from @t)

insert into @res (ID) 
select B.ID 
from @t A
left join FC_REPORT B with(nolock) on B.SN = A.SN and B.MODELID = A.MODELID
where B.ID is not null
  and B.DEVICEID is null
  

return

end