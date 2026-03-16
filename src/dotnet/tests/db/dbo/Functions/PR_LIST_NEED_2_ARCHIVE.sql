CREATE function [dbo].[PR_LIST_NEED_2_ARCHIVE] ()
returns @res table (DEVICEID int, ORDERID int, LASTTS datetime, REPEAT int)
as 
begin
/*возвращает <изделие + заказ + дата_модификации> по которым можно писать протоколы в архив протоколов*/


/* сервисные */
insert into @res (DEVICEID, ORDERID, LASTTS, REPEAT)
select top 100
     M.DEVICEID
    ,M.ORDERID
	,M.LASTTS
	,(select 1 where exists (select FF.ID from PR_DEVICE_WAS_ARCHIVED FF with (nolock) where FF.DEVICEID = M.DEVICEID and FF.ORDERID = M.ORDERID)) as REPEAT 
from (
select A.DEVICEID,A.ORDERID
  ,(select max(isnull(O.S_CDT,O.S_MDT)) from PR_OPERATION O with (nolock) where O.ORDERID = A.ORDERID and O.DEVICEID = A.DEVICEID)  as LASTTS
from PR_PRORDER_SERVICE A with (nolock)
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
left join PR_MODELS M with (nolock) on M.ID = D.MODELID
where A.SCOMPLETED_DT > '20160101' 
  and isnull(B.TESTORDER,0) = 0
  and D.S_S not in (1000078/*failed*/)
  and B.ORDERTYPE > 0
  and D.SN not like 'SN not assigned%'
group by A.DEVICEID,A.ORDERID
)M  
where not exists (select F.ID from PR_DEVICE_WAS_ARCHIVED F with (nolock)
                 where F.DEVICEID = M.DEVICEID 
   		           and F.ORDERID = M.ORDERID 
				   and F.LASTCHANGES_TIMESTAMP = M.LASTTS)
  
  
/*производственные*/  

insert into @res (DEVICEID, ORDERID, LASTTS, REPEAT)
select top 100
     M.DEVICEID
    ,M.ORDERID
	,M.LASTTS
	,(select 1 where exists (select FF.ID from PR_DEVICE_WAS_ARCHIVED FF with (nolock) where FF.DEVICEID = M.DEVICEID and FF.ORDERID = M.ORDERID)) as REPEAT 
from (
select A.DEVICEID,A.ORDERID,max(isnull(A.S_CDT,A.S_MDT)) as LASTTS
from PR_OPERATION A with (nolock)
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
left join PR_MODELS M with (nolock) on M.ID = D.MODELID
where D.COMPLETED_DT > '20160101' 
  and isnull(B.TESTORDER,0) = 0
  and B.S_S not in (1000113,1000114)
  and D.S_S not in (1000078/*failed*/,1000101/*canceled*/)
  and B.ORDERTYPE = 0
  and D.SN not like 'SN not assigned%'
group by A.DEVICEID,A.ORDERID
)M  
where not exists (select F.ID from PR_DEVICE_WAS_ARCHIVED F with (nolock)
                 where F.DEVICEID = M.DEVICEID 
   		           and F.ORDERID = M.ORDERID 
				   and F.LASTCHANGES_TIMESTAMP = M.LASTTS)
     

return

end