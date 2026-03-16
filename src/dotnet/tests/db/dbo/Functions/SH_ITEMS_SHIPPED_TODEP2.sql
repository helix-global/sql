CREATE function [dbo].[SH_ITEMS_SHIPPED_TODEP2] (@aMTID int, @aDepID int,@aDepID2 int,@aMode int)
returns @res table (ID int)
as 
begin

/*
KB561 
v2: берет только конкретный MT
    берет supply и prod. order для определения TODEPID если TODEPID не заполняется
    используется 2 parent
*/

insert into @res (ID)
select B.DEVICEID 
from SH_ORDER A with (nolock)
left join SH_ORDER_T B with (nolock) on B.SHORDERID = A.ID
left join PR_DEVICE C with (nolock) on C.ID = B.DEVICEID
left join PR_MODELS M with (nolock) on M.ID = C.MODELID
where A.S_S = 1000024 /*shipped*/
  and M.TYPEID = @aMTID
  and A.TODEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS3(@aDepID,@aDepID2,1))
  
insert into @res (ID)
select A.ID 
from PR_DEVICE A with (nolock)
left join PR_SUPPLY D with (nolock) on D.ID = A.SORDERID
left join PR_PRORDER E with (nolock) on E.ID = A.ORDERID
left join PR_MODELS M with (nolock) on M.ID = A.MODELID
where A.SHIPPED_DT is not null
  and M.TYPEID = @aMTID
  and isnull(D.CUSTOMERID,E.CUSTOMERID) in (select JJ.CUSTOMERID 
                                              from COM_DEPARTMENTS JJ with (nolock)
                                             where JJ.ID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS3(@aDepID,@aDepID2,1))
                                             )
  

return

end