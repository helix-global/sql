CREATE procedure [dbo].[PR_BIND2NAVI] @OperID int,@Mode int,@aUserID int, @aDate datetime
WITH EXECUTE AS OWNER , RECOMPILE
as 
SET nocount on
/*
  @Mode = 1 - add
  @Mode = 2 - remove
*/


declare @BindCode nvarchar(20)
declare @DevicePosted int 
declare @inventoryMode int
declare @revOperID int
declare @OperTypeID int
declare @orderType int
declare @serviceOrd nvarchar(20)
declare @depCode nvarchar(20)
declare @ordn nvarchar(20)
declare @ordn2 nvarchar(10)
declare @depID int
declare @resultQty decimal(20,3)

select @BindCode = MO.BCODE
     ,@DevicePosted = isnull(D.DEVICEPOSTED,0)
     ,@inventoryMode = ISNULL(MM.INVENTORYMODE,0)
     ,@revOperID = D.REVOPERID
     ,@OperTypeID = D.OPERTYPEID
     ,@ordn = O.NN
     ,@orderType = O.ORDERTYPE
     ,@depID = O.DEPARTMENTID
     ,@depCode = SUBSTRING(isnull(DD.POSTINGCODE,DD.CODE),1,20)
     ,@resultQty = isnull(D.PREP_RESULT,1)
from PR_OPERATION D with (nolock) 
left join PR_MAP_OPER MO with (nolock) on MO.ID = D.REVOPERID
left join PR_PRORDER O on O.ID = D.ORDERID
left join PR_NAV_DEPMODES MM on MM.DEPID = O.DEPARTMENTID
left join COM_DEPARTMENTS DD on DD.ID = O.DEPARTMENTID
where D.ID = @OperID

if @BindCode is null and @revOperID is null 
begin
   /*операция не по карте, видимо ремонтная, попытка взять код с карты если там есть та-же операция */
   
   select top 1 @BindCode = A.BCODE
   from PR_OPERATION D with (nolock) 
   left join PR_DEVICE B on B.ID = D.DEVICEID
   left join PR_REVISION C on C.ID = B.REVID
   left join PR_MAP_OPER A on A.MAPID = C.MAPID
   where D.ID = @OperID
     and A.BCODE is not null
     and A.OPERID = D.OPERTYPEID

end


if (@Mode = 1) and (@DevicePosted = 1)
  set @BindCode = null /* уже запостили */

if (@Mode = 2) and (@DevicePosted = 0)
  set @BindCode = null /* не постили раньше - нечего возвращать */


if @BindCode is not null
begin

    set @ordn = ltrim(@ordn)
	set @serviceOrd = null
	set @ordn2 = SUBSTRING(@ordn,1,10)

	if @orderType = 1 /*service*/
	begin
	  if substring(UPPER(@ordn),1,3) <> 'MOF'
	  begin 
		 set @serviceOrd = @ordn
		 set @ordn2 = null
	  end
	end

    set @BindCode = UPPER(@BindCode)

	/*declare @quant int*/
	declare @quant decimal(20,3)
	set @quant = @resultQty
	if @Mode = 2
	  set @quant = -@resultQty

	insert into PDB_BUFFER..DEVICES(S_S,S_CR,S_CDT,PARTNUMBER,OUTDATE,SN,EVENT,BCODE,PRODUCTIONORDER,SERVICEORDER,QUANTITY,OPERATIONID,DEPID,LOCATION)
	select 1,@aUserID,@aDate,C.CODE,@aDate,upper(B.SN),1,upper(@BindCode),@ordn2,@serviceOrd,@quant,A.ID,@depID,upper(@depCode)
	from PR_OPERATION A with (nolock)
	left join PR_DEVICE B on B.ID = A.DEVICEID
	left join PR_MODELS C on C.ID = B.MODELID
	where A.ID = @OperID

	declare @newSS int
	set @newSS = 1000073
	if @inventoryMode = 1
	   set @newSS = 1000084

	update PDB_BUFFER..DEVICES set S_S = @newSS where OPERATIONID = @OperID and S_S = 1

    if (@Mode = 1)
      update PR_OPERATION set DEVICEPOSTED = 1 where ID = @OperID

    if (@Mode = 2)
      update PR_OPERATION set DEVICEPOSTED = 0 where ID = @OperID


end

SET nocount off