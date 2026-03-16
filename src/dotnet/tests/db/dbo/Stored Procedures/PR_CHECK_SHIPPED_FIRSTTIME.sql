CREATE procedure [dbo].[PR_CHECK_SHIPPED_FIRSTTIME]
as 
SET nocount on


declare @ids table (ID int)

insert into @ids (ID)
select top 9000 A.ID
from PR_DEVICE A with (nolock)
where A.SHIPPED_DT is not null
  and A.SHIPPED_FIRSTTIME is null
  
update PR_DEVICE set SHIPPED_FIRSTTIME = (select top 1 BB.DD from SH_ORDER_T AA with (nolock) left join SH_ORDER BB with (nolock) on BB.ID = AA.SHORDERID where AA.DEVICEID = PR_DEVICE.ID and BB.S_S = 1000024 order by AA.ID)
where PR_DEVICE.ID in (select ID from @ids)
  and PR_DEVICE.SHIPPED_FIRSTTIME is null

update PR_DEVICE set SHIPPED_FIRSTTIME = SHIPPED_DT
where PR_DEVICE.ID in (select ID from @ids)
  and PR_DEVICE.SHIPPED_FIRSTTIME is null


/* если изделие отгружалось 1 раз и по нему не было ремонтов, и отличие SHIPPED_DT,A.SHIPPED_FIRSTTIME в пределах ~10 дней 
то скорее всего отличие в том что день shipment request не равен дню его исполнения */
update PR_DEVICE set SHIPPED_FIRSTTIME = SHIPPED_DT
where ID in (
select A.ID
from PR_DEVICE A with (nolock)
where A.ID in (select ID from @ids)
  and A.SHIPPED_DT is not null
  and A.SHIPPED_FIRSTTIME is not null
  and abs(datediff(day,A.SHIPPED_DT,A.SHIPPED_FIRSTTIME)) < 10
  and cast(A.SHIPPED_DT as date) <> cast(A.SHIPPED_FIRSTTIME as date)
  and (select count(*) from SH_ORDER_T KK with (nolock) where KK.DEVICEID = A.ID) = 1
  and not exists (select LL.ID from PR_PRORDER_SERVICE LL with (nolock) where LL.DEVICEID = A.ID)
)  

print @@rowcount

SET nocount off