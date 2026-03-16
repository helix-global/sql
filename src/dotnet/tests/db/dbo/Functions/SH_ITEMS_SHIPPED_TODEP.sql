create function [dbo].[SH_ITEMS_SHIPPED_TODEP] (@aDepID int,@aMode int)
returns @res table (ID int)
as 
begin

insert into @res (ID)
select B.DEVICEID 
from SH_ORDER A with (nolock)
left join SH_ORDER_T B with (nolock) on B.SHORDERID = A.ID
where A.S_S = 1000024 /*shipped*/
  and A.TODEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@aDepID,1))

return

end