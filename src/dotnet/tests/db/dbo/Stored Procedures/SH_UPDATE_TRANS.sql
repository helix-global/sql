create procedure [dbo].[SH_UPDATE_TRANS] @ShipID int, @UserID int 
as
set nocount on

declare @tt table (ID int primary key, DEVICEID int, NCUSTID int, NDEPID int, IO int, ORDER_NN nvarchar(50), TRANSFMODE int)
insert into @tt (ID, DEVICEID, NDEPID)
select A.ID, A.DEVICEID, B.TODEPID
from SH_ORDER_T A
left join SH_ORDER B on B.ID = A.SHORDERID
where A.SHORDERID = @ShipID

update @tt set ORDER_NN = (select top 1 isnull(KS.ND,KK.NN2) 
  from PR_DEVICE K 
  left join PR_PRORDER KK on KK.ID = K.ORDERID
  left join PR_SUPPLY KS on KS.ID = K.SORDERID
 where K.ID = "@tt".DEVICEID)
   
update @tt set NCUSTID = (select top 1 isnull(KS.CUSTOMERID,KK.CUSTOMERID)  
  from PR_DEVICE K 
  left join PR_PRORDER KK on KK.ID = K.ORDERID
  left join PR_SUPPLY KS on KS.ID = K.SORDERID
 where K.ID = "@tt".DEVICEID)
   
update @tt set IO = 1 where ORDER_NN like 'IO-%'   

update @tt set TRANSFMODE = 1 /*to IPM*/ where ORDER_NN like 'IPM-%'   

update @tt set TRANSFMODE = 2 /*to IPGL*/ where isnull(IO,0) = 0 and NDEPID is not null and dbo.COM_TOP_PARENT_DEPCODE(NDEPID) = 'IPGL' 

update SH_ORDER_T set TRMODE = null where SHORDERID = @ShipID and isnull(TRMODE,0) < 100
update SH_ORDER_T set TRMODE = (select TRANSFMODE from @tt where "@tt".ID = SH_ORDER_T.ID) where SHORDERID = @ShipID and TRMODE is null

set nocount off