create function [dbo].[PR_NEED_2BE_ARCHIVED_SRV] ()
returns table
as
return
(
	select 
		 M.DEVICEID
		,M.ORDERID
		,isnull(M.LASTTS,'20000101') as LASTTS
		,(select 1 where exists (select FF.ID from PR_DEVICE_WAS_ARCHIVED FF with (nolock) where FF.DEVICEID = M.DEVICEID and FF.ORDERID = M.ORDERID)) as REPEAT 
	from (
	select A.DEVICEID,A.ORDERID
	  ,(select max(isnull(O.S_CDT,O.S_MDT)) from PR_OPERATION O with (nolock) where O.ORDERID = A.ORDERID and O.DEVICEID = A.DEVICEID)  as LASTTS
	from PR_PRORDER_SERVICE A with (nolock)
	left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
	left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
	left join PR_MODELS M with (nolock) on M.ID = D.MODELID
	where A.SCOMPLETED_DT >= '20160101' 
	  and isnull(B.TESTORDER,0) = 0
	  and D.S_S not in (1000078/*failed*/,1000011/*in service*/)
	  and B.ORDERTYPE > 0
	  and D.SN not like 'SN not assigned%'
	  and exists (select J.ID from PR_OPERATION J with (nolock) where J.DEVICEID = A.DEVICEID and J.ORDERID = A.ORDERID and J.COMPLETED_DT is not null and J.S_S <> 1000023 /*canceled*/ )
	group by A.DEVICEID,A.ORDERID
	)M  
	where not exists (select F.ID from PR_DEVICE_WAS_ARCHIVED F with (nolock)
					 where F.DEVICEID = M.DEVICEID 
   					   and F.ORDERID = M.ORDERID 
					   and F.LASTCHANGES_TIMESTAMP = M.LASTTS)
)