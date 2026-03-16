CREATE procedure [dbo].[PR_CHECK_PLACED_ORDERS_2NAV2] @OrderID int, @UserID int, @aMode int
WITH EXECUTE AS OWNER , RECOMPILE
as 
set nocount on
/*

  Проверяет настройки размещения заказа и, если нужно, отправляет в буфер.
  Клиент PDB если найдет GID в буфере по текущему заказу записи, то 
  вызовет NavisionUtils
  
  @aMode - 1 размещается сам заказ, переданный в @OrderID
  TODO ??? :
  @aMode - 2 размещаются дочерние по отношению к @OrderID заказы (м.б. несколько)
  
  Отличается от PR_CHECK_PLACED_ORDERS_2NAV тем, что возвращает несколько guid'ов - после этого
  в PDB запускается добавление заказов в NAV по отдельности (невозможно запустить добавление пакетно
  в силу ограничение функционала NAV)
*/

declare @orders table (ID int not null primary key, guid_val nvarchar(50))

if @aMode = 1
begin

   insert into @orders (ID, guid_val) 
   select A.ID, NEWID()
   from PR_PRORDER A with (nolock)
   left join PR_PLACED_SETTINGS B with (nolock) on B.ID = A.PLACEDSETTINGID
   where A.ID = @OrderID
     and isnull(B.NAVIO,0) = 1
     and A.S_S = 1000063 /* placed */

end
else if @aMode = 2
begin

   insert into @orders (ID, guid_val) 
   select A.ID, NEWID()
   from PR_PRORDER A with (nolock)
   left join PR_PLACED_SETTINGS B with (nolock) on B.ID = A.PLACEDSETTINGID
   where A.PARENTORDER = @OrderID
     and isnull(B.NAVIO,0) = 1
     and A.S_S = 1000063 /* placed */

end

declare @cou int
select @cou = count(*) from @orders

if @cou = 0
begin
  set nocount off
  return 
end
/*
if @cou > 1
  raiserror('Sending more that 1 order to Navision is not supported.',16,0)
  */
declare @now datetime
set @now = getdate()

delete from PDB_BUFFER..SHIPMENT where ORDERID in (select ID from @orders)

declare @SessionID nvarchar(50)
set @SessionID = NEWID()

insert into PDB_BUFFER..SHIPMENT(SESSIONID, PRODUCTIONORDER, DESTINATIONLOCATION, OUTDATE, READYTOSHIPMENT, PICKUPLOCATION, PARTNUMBER, QUANTITY, ADDINFORMATION, ORDERREFERENCE, SN, DEPID, LOCATION, ORDERID)
select
	o.guid_val
	,ord.NN
	,cust.NAME as DESTINATIONLOCATION
	,@now as OUTDATE
	,ord.EXPDATE as READYTOSHIPMENT
	,ISNULL(dep.PLACECODE, dep.CODE) as PICKUPLOCATION
	,mdl.CODE  as PARTNUMBER
	,ordt.QUANTITY as QUANTITY
	,null as ADDINFORMATION
	,dbo.PR_PARENORDER_REFERENCE_TXT(ord.ID) as ORDERREFERENCE
	,null as SN
	,ord.DEPARTMENTID
	,ISNULL(dep.PLACECODE, dep.CODE)
	,ord.ID
from PR_PRORDER ord
join PR_PRORDER_T ordt on ord.ID = ordt.PRORDERID
	join PR_MODELS mdl on ordt.MODELID = mdl.ID
left join COM_CUSTOMER cust on ord.CUSTOMERID = cust.ID
left join COM_DEPARTMENTS dep on ord.DEPARTMENTID = dep.ID
	join @orders o on ord.ID=o.ID
union all
select
	o.guid_val
	,ord.NN
	,cust.NAME as DESTINATIONLOCATION
	,@now as OUTDATE
	,ord.EXPDATE as READYTOSHIPMENT
	,ISNULL(dep.PLACECODE, dep.CODE) as PICKUPLOCATION
	,mopt.CODE  as PARTNUMBER
	,ISNULL(opt.QUANTITY, ordt.QUANTITY) as QUANTITY
	,null as ADDINFORMATION
	,dbo.PR_PARENORDER_REFERENCE_TXT(ord.ID) as ORDERREFERENCE
	,null as SN
	,ord.DEPARTMENTID
	,ISNULL(dep.PLACECODE, dep.CODE)
	,ord.ID
from PR_PRORDER ord
join PR_PRORDER_T ordt on ord.ID = ordt.PRORDERID
	join PR_PRORDER_TO opt on ordt.ID = opt.OPID
		join PR_MODELTYPE_OPTIONS mopt on opt.OPTID = mopt.ID
left join COM_CUSTOMER cust on ord.CUSTOMERID = cust.ID
left join COM_DEPARTMENTS dep on ord.DEPARTMENTID = dep.ID
	join @orders o on ord.ID=o.ID
where isnull(mopt.INTOPTION,0) <> 1

update PR_PRORDER set PR_PRORDER.OUT2NAVGID = o.guid_val 
	from PR_PRORDER P join @orders o on P.ID=o.ID

select guid_val from @orders

set nocount off