CREATE PROCEDURE [dbo].[SM_RECIEVE_RMA]  @UserID int, @aMode int
WITH EXECUTE AS OWNER , RECOMPILE
AS
BEGIN
set nocount on


declare @cases table (REQUESTID int not null, SCASEID int not null, RMA nvarchar(20), SERVORDID int, ERRTEXT nvarchar(50), RCOMMENT nvarchar(50), S_CR int, EXSERVORDID int)

/* в @cases отбираются те, что обработаны Навижен (и удачно и неудачно обработанные)
   A.S_S = 1000198 /*processed*/ - недостаточно т.к. Навижен проставляет этот признак когда запись взята, но результата еще нет
   добавлено A.STATUS in (5,4,2) т.к. этими цифрами кодируется одно из 3-х финальных состояния обработки
*/
insert into @cases (REQUESTID, SCASEID, RMA, ERRTEXT, RCOMMENT, S_CR)
select A.ID
     , A.SCASEID
	 , A.RESULTORDERNUMBER
	 , A.RESULTERROR
	 , A.RESULTCOMMENT
	 , A.S_CR
from PDB_BUFFER..SERVICEREQUEST A with (nolock)
where A.S_S = 1000198 /*processed*/
  and A.STATUS in (5,4,2)
  and exists (select B.ID from SM_SERVICECASE B with (nolock) where B.ID = A.SCASEID)
  and isnull(A.RECIEVED,0) <> 1



insert into SM_RMA_NOTIFICATIONS (GID,S_S,S_CR,S_CDT,REQUESTID,SCASEID 
                                  ,RESULT
                                  ,RESULTRMA
                                  ,RESULTERROR
                                  ,REQUEST_CR)
select newid(),1, @UserID, getdate() , A.REQUESTID, A.SCASEID
  ,case when len(RMA) > 3 then 1 /*RMA issued*/ else 0 /* error */ end as RESULT
  ,A.RMA
  ,isnull(A.ERRTEXT + ' ','') + isnull(A.RCOMMENT,'')
  ,A.S_CR
from @cases A
where not exists (select B.ID from SM_RMA_NOTIFICATIONS B where B.REQUESTID = A.REQUESTID)
  

if not exists (select REQUESTID from @cases)
begin
  set nocount off
  return
end
  
update SM_SERVICECASE set S_S = 2000012 /*issued*/  
where ID in (select SCASEID from @cases where len(RMA) > 3) and S_S = 1000193

update SM_SERVICECASE set S_S = 1000191 /*open*/ ,RMA_SC_REQUESTED = null
where ID in (select SCASEID from @cases where len(RMA) < 3) and S_S = 1000193


update @cases set EXSERVORDID = (select top 1 H.ID from PR_PRORDER H with (nolock) where H.NN = "@cases".RMA)
where len(RMA) > 3


insert into PR_PRORDER (GID, S_S, S_CR, S_CDT, ORDERTYPE, NN, DD, CUSTOMERID, DEPARTMENTID, RMAREQUESTID, URGENCY)
select newid()
  ,1
  ,@UserID
  ,getdate()
  ,1
  ,A.RMA
  ,cast(getdate() as date)
  ,B.CUSTID
  ,B.SDEPID
  ,A.REQUESTID
  ,1
from @cases A
left join SM_SERVICECASE B with (nolock) on B.ID = A.SCASEID
where len(A.RMA) > 3
  and A.SCASEID is not null  
  and B.SERVORDID is null
  and A.EXSERVORDID is null
  
  
update @cases set SERVORDID = (select H.ID from PR_PRORDER H with (nolock) where H.RMAREQUESTID = "@cases".REQUESTID)
where len(RMA) > 3
      
insert into PR_PRORDER_SERVICE (GID, S_CR, S_CDT, ORDERID, DEVICEID, FRID)
select newid()
,@UserID
,getdate()
,SERVORDID
,ID
,FRID
from (
select distinct
A.SERVORDID
,D.ID
,min(L.FRID) as FRID  /*KB3978*/
from @cases A
left join PDB_BUFFER..SERVICEREQUESTLINES B with (nolock) on B.HEADERID = A.REQUESTID
left join PR_MODELS C with (nolock) on C.CODE = B.ITEMNO collate database_default
left join PR_DEVICE D with (nolock) on D.MODELID = C.ID and D.SN = B.SERIALNO collate database_default
left join SM_SERVICECASE_ITEMS L with (nolock) on L.ID = B.SCASEITEMID
where D.ID is not null
  and A.SERVORDID is not null
  and A.EXSERVORDID is null
  and not exists (select G.ID from PR_PRORDER_SERVICE G where G.ORDERID = A.SERVORDID and G.DEVICEID = D.ID)
group by A.SERVORDID, D.ID
) M  

update SM_SERVICECASE set SERVORDID = (select SERVORDID from @cases B where B.SCASEID = SM_SERVICECASE.ID)
where ID in (select SCASEID from @cases where len(RMA) > 3 and EXSERVORDID is null) 
  and SERVORDID is null
  and S_S = 2000012 /*issued*/  

declare @fars table (FRID int not null, RMA nvarchar(50), RMA_TYPE int, RMA_N nvarchar(50))

insert into @fars (FRID, RMA)
select distinct C.FRID, A.RMA
from @cases A
left join SM_SERVICECASE B with (nolock) on B.ID = A.SCASEID
left join SM_SERVICECASE_ITEMS C with (nolock) on C.VNESHID =B.ID
where C.FRID is not null
  and len(A.RMA) > 3

update @fars set RMA_TYPE = 1/*INT*/  , RMA_N = substring(RMA,5,99) where RMA like 'INT-%'  
update @fars set RMA_TYPE = 2/*RMA*/  , RMA_N = substring(RMA,5,99) where RMA like 'RMA-%' 
update @fars set RMA_TYPE = 3/*SC*/   , RMA_N = substring(RMA,4,99) where RMA like 'SC-%' 
update @fars set RMA_TYPE = 4/*SCAFF*/, RMA_N = substring(RMA,7,99) where RMA like 'SCAFF-%' 

update FC_REPORT set RMA_TYPE = (select top 1 B.RMA_TYPE from @fars B where B.FRID = FC_REPORT.ID)
                   , RMA = (select top 1 B.RMA_N from @fars B where B.FRID = FC_REPORT.ID)
where FC_REPORT.ID in (select F.FRID from @fars F where F.RMA_TYPE is not null and F.RMA_N is not null)
  and FC_REPORT.RMA is null

update PDB_BUFFER..SERVICEREQUEST set RECIEVED = 1 where ID in (select REQUESTID from @cases)

set nocount off

END