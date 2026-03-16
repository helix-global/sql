CREATE procedure [dbo].[PR_ORDER2NAVI] @OrderID int, @UserID int 
WITH EXECUTE AS OWNER , RECOMPILE
as
set nocount on

declare @SessionID uniqueidentifier =  NEWID()

delete from PDB_BUFFER..SHIPMENT where ORDERID = @OrderID

insert into PDB_BUFFER..SHIPMENT(ORDERID,SESSIONID,PRODUCTIONORDER,DESTINATIONLOCATION,OUTDATE,READYTOSHIPMENT,PICKUPLOCATION,PARTNUMBER,QUANTITY,ADDINFORMATION,SN,DEPID,LOCATION)
select
     @OrderID
	,@SessionID
	,ord.NN
	,cust.NAME as [DESTINATIONLOCATION]
	,GETDATE() as [OUTDATE]
	,ord.EXPDATE as [READYTOSHIPMENT]
	,ISNULL(dep.PLACECODE, dep.CODE) as PICKUPLOCATION
	,mdl.CODE  as [PARTNUMBER]
	,ordt.QUANTITY as [QUANTITY]
	,null as [ADDINFORMATION]
	,null as SN
	,ord.DEPARTMENTID
	,ISNULL(dep.PLACECODE, dep.CODE)
from PR_PRORDER ord
join PR_PRORDER_T ordt on ord.ID = ordt.PRORDERID
	join PR_MODELS mdl on ordt.MODELID = mdl.ID
left join COM_CUSTOMER cust on ord.CUSTOMERID = cust.ID
left join COM_DEPARTMENTS dep on ord.DEPARTMENTID = dep.ID
where
	ord.ID = @OrderID
union all
select
     @OrderID
	,@SessionID
	,ord.NN
	,cust.NAME as [DESTINATIONLOCATION]
	,GETDATE() as [OUTDATE]
	,ord.EXPDATE as [READYTOSHIPMENT]
	,ISNULL(dep.PLACECODE, dep.CODE) as PICKUPLOCATION
	,mopt.CODE  as [PARTNUMBER]
	,ISNULL(opt.QUANTITY, ordt.QUANTITY) as [QUANTITY]
	,null as [ADDINFORMATION]
	,null as SN
	,ord.DEPARTMENTID
	,ISNULL(dep.PLACECODE, dep.CODE)
from PR_PRORDER ord
join PR_PRORDER_T ordt on ord.ID = ordt.PRORDERID
	join PR_PRORDER_TO opt on ordt.ID = opt.OPID
		join PR_MODELTYPE_OPTIONS mopt on opt.OPTID = mopt.ID
left join COM_CUSTOMER cust on ord.CUSTOMERID = cust.ID
left join COM_DEPARTMENTS dep on ord.DEPARTMENTID = dep.ID
where
	ord.ID = @OrderID

set nocount off