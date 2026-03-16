CREATE procedure [dbo].[PR_TIME2NAVI_COMMON_D] @OperID int, @Mode int, @aUserID int, @aDate datetime
WITH EXECUTE AS OWNER, RECOMPILE
as 
SET nocount on

declare @sn nvarchar(20)
declare @ordn nvarchar(20)
declare @ordn2 nvarchar(20)
declare @operCode nvarchar(20)
declare @TimePosted int
declare @depID int
declare @operGrID int
declare @TimeShiftMode int
declare @TimeShiftValue decimal(12,2)
declare @TimeShiftQualification int
declare @inventoryMode int
declare @orderType int
declare @serviceOrd nvarchar(20)
declare @depCode nvarchar(20)
declare @TimeShiftParamID int
declare @DelayedMode int
declare @DeviceID int
declare @OrderID int
declare @RevID int
declare @MapOperID int
declare @rootServiceItemSN nvarchar(20) = null
declare @mdlID int
declare @MultiplyQty int

select 
  @sn = D.SN, 
  @ordn = O.NN,
  @operCode = OG.OPERCODE,
  @TimePosted = isnull(A.TIMEPOSTED,0),
  @depID = O.DEPARTMENTID,
  @operGrID = OS.OPERGRID,
  @TimeShiftMode = ISNULL(MO.TC_ACTION,0),
  @TimeShiftValue = isnull(MO.TC_MINUTE,0),
  @TimeShiftQualification = MO.TC_QUALIFICATION,
  @TimeShiftParamID = MO.TC_PARAMID,
  @orderType = O.ORDERTYPE,
  @depCode = SUBSTRING(isnull(DD.POSTINGCODE,DD.CODE),1,20),
  @DelayedMode = isnull(OS.DELAYEDPOST,0),
  @DeviceID = A.DEVICEID,
  @OrderID = A.ORDERID,
  @RevID = D.REVID,
  @MapOperID = A.REVOPERID,
  @mdlID = D.MODELID,
  @MultiplyQty = (case when D2.MULTREVADDTIMES = 1 then isnull(A.PREP_RESULT,1) else 1 end)
from PR_OPERATION A with (nolock)
left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
left join PR_OPERATIONS OS with (nolock) on OS.ID = A.OPERTYPEID
left join PR_OPERATIONS_GR OG with (nolock) on OG.ID = OS.OPERGRID
left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
left join COM_DEPARTMENTS DD with (nolock) on DD.ID = O.DEPARTMENTID
left join PR_MODELS C2 with(nolock) on C2.ID = D.MODELID
left join PR_MODELTYPE D2 with(nolock) on D2.ID = C2.TYPEID
where A.ID = @OperID

if (@Mode = 1 and @TimePosted = 1)
begin
   set nocount off
   return
end

select top 1 @inventoryMode = isnull(MM.INVENTORYMODE,0)
from PR_NAV_DEPMODES MM with (nolock) 
where MM.DEPID = @depID


declare @timings table (EMPLNUMBER nvarchar(20),QUANTITY decimal(12,2),QUALIFICATION int,OPERCODE nvarchar(20))
insert into @timings (EMPLNUMBER,QUANTITY,QUALIFICATION)
select 
   isnull(rtrim(ltrim(cast(E.PERSONALNO as nvarchar(20)))),'NA')
  ,A.ELAPSED_D
  ,E.QUALIFICATION
from PR_OPERATION_TIME A
left join COM_EMPLOYEE E with (nolock) on E.ID = A.EMPID
left join PR_OPERATION O with (nolock) on O.ID = A.OPERID
where A.OPERID = @OperID

if (@TimeShiftMode = 4 /*KB1670*/) 
begin
	declare @addFromParam decimal(16,2)
	set @addFromParam = dbo.PR_OPER_RAW_ADDFROMPARAM_TIME(@OperID,@TimeShiftParamID)
	if @addFromParam is not null
	begin
		insert into @timings (EMPLNUMBER,QUANTITY,QUALIFICATION)
		select '0',@addFromParam,isnull(@TimeShiftQualification,1)
	end
end

if @TimeShiftMode = 3 /* plus by parameter */
begin
  if exists (select G.ID from PR_OPERATION_PARAMS G where G.OPERID = @OperID and G.PARAMID = @TimeShiftParamID and dbo.DEF_VARIANT2BOOL(G.PVALUE) = 1)
  begin 
    insert into @timings (EMPLNUMBER,QUANTITY,QUALIFICATION)
    select '0',@TimeShiftValue,isnull(@TimeShiftQualification,1)
  end
end 

if @TimeShiftMode in (2,4) /* plus */
begin
  insert into @timings (EMPLNUMBER,QUANTITY,QUALIFICATION)
  select '0',@TimeShiftValue,isnull(@TimeShiftQualification,1)
end 

if @TimeShiftMode = 1 /* = */
begin
  delete from @timings
  insert into @timings (EMPLNUMBER,QUANTITY,QUALIFICATION)
  select '0',@TimeShiftValue,isnull(@TimeShiftQualification,1)
end  

update @timings set OPERCODE = (select B.OPERCODE 
                                  from PR_OPERATIONS_GRQ B with (nolock) 
                                 where B.VNESHID = @operGrID 
                                   and B.QUALIFICATION = "@timings".QUALIFICATION)
                                   
update @timings set OPERCODE = @operCode where OPERCODE is null

/*04.02.2019*/
insert into @timings (EMPLNUMBER,QUANTITY,QUALIFICATION,OPERCODE)
select '0',A.ADDVALUE * isnull(@MultiplyQty,1),A.QUALIFICATION,A.NAVCODE
from PR_REV_ADD_TIMES A with (nolock)
where A.REVID = @RevID
  and A.MAPOPERID = @MapOperID

insert into PR_DEVICE_PROD_SUPP (DEVICEID,QUALIFICATION,ELAPSED)
select @DeviceID, A.QUALIFICATION, A.ADDVALUE * isnull(@MultiplyQty,1) * (case @Mode when 2 then -1 else 1 end)
from PR_REV_ADD_TIMES A with (nolock)
where A.REVID = @RevID
  and A.MAPOPERID = @MapOperID

if (@Mode = 2)
begin
  update @timings set QUANTITY = -QUANTITY
end  

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
  
  select top 1 @rootServiceItemSN = A.ROOTSN
  from PR_PRORDER_SERVICE A with (nolock)
  where A.ORDERID = @OrderID
    and A.DEVICEID = @DeviceID
    and A.ROOTSN is not null
  
  if upper(@serviceOrd) like 'RMA%.%'
  begin 
    set @serviceOrd = dbo.PR_RMA_CUT_LASTPART2(@serviceOrd,@depID,@mdlID, 0)
  end  
 
  
end

insert into PDB_BUFFER..TIMINGS (S_S,S_CR,S_CDT,OPERATIONCODE,OUTDATE,SN,QUANTITY,PRODUCTIONORDER,SERVICEORDER,EMPLOYEENUMBER,OPERATIONID,DEPID,LOCATION,ROOTSERVICEITEMSN)
select 
   1
  ,@aUserID
  ,@aDate
  ,OPERCODE
  ,@aDate
  ,upper(@sn)
  ,SUM(QUANTITY)
  ,@ordn2
  ,@serviceOrd
  ,EMPLNUMBER
  ,@OperID
  ,@depID
  ,@depCode
  ,@rootServiceItemSN
from @timings
where QUANTITY <> 0
group by EMPLNUMBER,OPERCODE

update PR_OPERATION set TIMEPOSTED = 1 where ID = @OperID

declare @newSS int
set @newSS = 1000046
if @inventoryMode = 1
   set @newSS = 1000093
   
if @DelayedMode = 1
   set @newSS = 1000145

update PDB_BUFFER..TIMINGS 
   set S_S = @newSS 
 where OPERATIONID = @OperID and S_S = 1

if @newSS = 1000046
begin

  /* если идет не отложенный постинг - проставить нормальный статус по ранее отложенным */
  update PDB_BUFFER..TIMINGS 
     set S_S = @newSS
        ,OUTDATE = GetDate() 
   where OPERATIONID in (select A.ID from PR_OPERATION A where A.DEVICEID = @DeviceID and A.ORDERID = @OrderID)
     and S_S = 1000145
  
end

SET nocount off