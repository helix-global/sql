CREATE procedure [dbo].[PR_OPER_ANNUL_POSTINGS_IPM] @OperID int, @aUserID int, @aDate datetime
WITH EXECUTE AS OWNER, RECOMPILE
as 
SET nocount on

declare @sn nvarchar(20)
declare @ordn nvarchar(20)
declare @ordn2 nvarchar(20)
declare @emplN nvarchar(20)
declare @devID int
declare @depID int
declare @mtID int
declare @cou int
declare @inventoryMode int
declare @bindPostedFlag int
declare @newSS int
declare @BindCode nvarchar(20)
declare @DeviceModelCode nvarchar(50)
declare @depCode nvarchar(20)
declare @serviceOrd nvarchar(20)
declare @orderType int
declare @resultQty decimal(20,3)

select 
  @sn = D.SN 
  ,@ordn = O.NN
  ,@devID = A.DEVICEID
  ,@mtID = M.TYPEID
  ,@depID = O.DEPARTMENTID
  ,@inventoryMode = isnull(MM.INVENTORYMODE,0)
  ,@bindPostedFlag = ISNULL(A.DEVICEPOSTED,0)
  ,@BindCode = MO.BCODE
  ,@DeviceModelCode = M.CODE
  ,@orderType = O.ORDERTYPE
  ,@depCode = SUBSTRING(isnull(DD.POSTINGCODE,DD.CODE),1,20)
  ,@resultQty = isnull(A.PREP_RESULT,1)
from PR_OPERATION A with (nolock)
left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
left join PR_MODELS M with (nolock) on M.ID = D.MODELID
left join PR_NAV_DEPMODES MM with (nolock) on MM.DEPID = O.DEPARTMENTID
left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
left join COM_DEPARTMENTS DD with (nolock) on DD.ID = O.DEPARTMENTID
where A.ID = @OperID

--select @emplN = isnull(ltrim(rtrim(str(B.PERSONALNO))),'NA')
select @emplN = isnull(rtrim(ltrim(cast(B.PERSONALNO as nvarchar(20)))),'NA')
from DEF_USERS A with (nolock) 
left join COM_EMPLOYEE B on B.ID = A.EMPLOYEEID
where A.ID = @aUserID

set @ordn = ltrim(@ordn)
set @serviceOrd = null
/*set @ordn2 = SUBSTRING(@ordn,1,10)*/
set @ordn2 = @ordn /* IPM! */

if @orderType = 1 /*service*/
begin
  if substring(UPPER(@ordn),1,3) <> 'MOF'
  begin 
     set @serviceOrd = @ordn
     set @ordn2 = null
  end
end

if exists (select ID from PR_NAVIOUT A where A.OPERID = @OperID)
begin
      
    insert into PDB_BUFFER..MATERIALS (S_S,S_CR,S_CDT,PARTNUMBER,OUTDATE,SN,QUANTITY,PRODUCTIONORDER,SERVICEORDER,EMPLOYEENUMBER,PARTSN,OPERATIONID,DEPID,LOCATION,FAILED,BATCHNUMBER)
    select
     1
    ,@aUserID
    ,@aDate
    ,A.PARTNUMBER
    ,@aDate
    ,upper(@sn)
    , - A.QUANTITY
    ,@ordn2
    ,@serviceOrd
    ,@emplN
    ,nullif(PARTSN,'-987')
    ,@OperID
    ,@depID
    ,upper(@depCode)
    ,case when ASDEFECTIVE = 1 then 1 else 0 end
    ,BATCHN
    from PR_NAVIOUT A 
    where A.OPERID = @OperID 
      and A.QUANTITY <> 0
      and (isnull(A.UNITEMSTAT,0) <> 1 or isnull(A.REPAIRABLE,0) <> 0)  /*17.02.2017 не отменять те, у которых UNITEMSTAT = 1 И REPAIRABLE = 0 т.к. они уходили в NAV с нулем*/

    delete from PR_NAVIOUT where OPERID = @OperID 

    set @newSS = 1000044
    if @inventoryMode = 1
       set @newSS = 1000068

    update PDB_BUFFER..MATERIALS set S_S = @newSS where OPERATIONID = @OperID and S_S = 1

end

if @bindPostedFlag = 1 and @BindCode is not null
begin

    insert into PDB_BUFFER..DEVICES(S_S,S_CR,S_CDT,PARTNUMBER,OUTDATE,SN,EVENT,BCODE,PRODUCTIONORDER,SERVICEORDER,QUANTITY,OPERATIONID,DEPID,LOCATION)
    values(1,@aUserID,@aDate,@DeviceModelCode,@aDate,upper(@sn),1,upper(@BindCode),@ordn2,@serviceOrd,-@resultQty,@OperID,@depID,upper(@depCode))

    set @newSS = 1000073
    if @inventoryMode = 1
       set @newSS = 1000084

    update PDB_BUFFER..DEVICES set S_S = @newSS where OPERATIONID = @OperID and S_S = 1

    update PR_OPERATION set DEVICEPOSTED = 0 where ID = @OperID  
    
end

update PDB_BUFFER..INCOMINGINSPECTION set S_S = 2000004 /*canceled*/ where OPERID = @OperID

SET nocount off