
create view PR_LAST_ORDER as
select A.ID as DEVICEID, isnull(SRV.ID, A.ORDERID) as ORDERID
from PR_DEVICE A with (nolock)
left join PR_PRORDER SRV on SRV.ID = (select top 1 D.ORDERID from PR_PRORDER_SERVICE D where D.DEVICEID = A.ID order by D.ORDERID desc)
where A.ORDERID is not null or exists (select D.ORDERID from PR_PRORDER_SERVICE D where D.DEVICEID = A.ID)