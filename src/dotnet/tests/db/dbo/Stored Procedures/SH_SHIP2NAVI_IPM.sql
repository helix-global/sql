CREATE procedure [dbo].[SH_SHIP2NAVI_IPM] @ShipID int, @UserID int 
WITH EXECUTE AS OWNER, RECOMPILE
as
set nocount on

update SH_ORDER set NAVSESSIONUID = null where ID = @ShipID

declare @DepID int
declare @NavMode int
declare @RS_Req int
declare @RS_Date datetime
declare @RS_Time datetime
declare @RS_Loc_Req int
declare @RS_Location nvarchar(30)
declare @Remark nvarchar(250)
declare @SpecialNotes nvarchar(50)
declare @addCheck_AllFrom1IO int

declare @SessionID nvarchar(500)
set @SessionID = upper(ltrim(rtrim(cast(newid() as nvarchar(50))))) 

select @DepID = A.DEPID 
      ,@NavMode = ISNULL(B.RUNNAVISION,0)
      ,@RS_Req = ISNULL(B.RS_REQUIRED,0)
      ,@RS_Loc_Req = ISNULL(B.RS_LOC_REQUIRED,0)
      ,@RS_Date = A.RS_DATE
      ,@RS_Time = A.RS_TIME
      ,@RS_Location = A.RS_LOCATION
      ,@Remark = A.REMARK
      ,@SpecialNotes = A.SPNOTES
      ,@addCheck_AllFrom1IO = isnull(ALL_FROM_ONE_IO,0)
from SH_ORDER A 
left join SH_SETTINGS B on B.DEPID = A.DEPID
where A.ID = @ShipID

if (@NavMode <> 1)
begin
  set nocount off
  return
end

if @RS_Req = 1
begin
   
   if @RS_Date is null or @RS_Time is null
      raiserror('Please specify "Ready To Shipment" date and time.',16,0) 

end

if @RS_Loc_Req = 1 and @RS_Location is null
      raiserror('Please specify shipment pickup location.',16,0) 


if @RS_Time is not null and @RS_Date is null
  set @RS_Date = GETDATE()

set @RS_Date = cast(cast(@RS_Date as date) as datetime) 
if @RS_Time is not null
  set @RS_Date = @RS_Date + cast(cast(@RS_Time as time) as datetime) 

if @SpecialNotes is not null
begin
  if @Remark is null
    set @Remark = @SpecialNotes 
  else
    set @Remark = @SpecialNotes + ' ' + isnull(@Remark,'')
end  

/*
дополнительная проверка для отделов FBA* (не работают по заказ, плюс оправляют блоки вообще без привязки к MOF, которые они получили из Фрязино
*/
if @addCheck_AllFrom1IO = 1
begin
  
  declare @errSN nvarchar(50)
  declare @errID int
  
  select top 1 
        @errID = A.ID
       ,@errSN = B.SN
   from SH_ORDER_T A with (nolock)
   left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
   left join PR_SUPPLY C with (nolock) on C.ID = B.SORDERID
  where A.SHORDERID = @ShipID
     and upper(isnull(C.ND,'NONE')) not like 'IO-%' 
     and upper(isnull(C.ND,'NONE')) not like 'SO-%' 
     and upper(isnull(C.ND,'NONE')) not like 'IPM-%' 
  /*
    and upper(isnull(dbo.PR_DEVICE_LAST_ORDER_N(B.ID,2),'NONE')) not like 'IO-%' 
    and upper(isnull(dbo.PR_DEVICE_LAST_ORDER_N(B.ID,2),'NONE')) not like 'SO-%' 
    and upper(isnull(dbo.PR_DEVICE_LAST_ORDER_N(B.ID,2),'NONE')) not like 'IPM-%' 
    */
  
  if @errID is not null
  begin
    declare @AddcheckErr nvarchar(max)
    set @AddcheckErr = 'Internal order number not specified for item '+isnull(@errSN,'NA')+'. Please link this item to supply order to specify internal order.'
    raiserror(@AddcheckErr,16,0) 
  end  
end


/*проверка что все изделия отсылаются после одного (SO- или IO-) заказа*/
declare @SOcou int
select @SOcou = COUNT (distinct isnull(SONN,'NA'))
from (select dbo.PR_DEVICE_LAST_ORDER_N(B.ID,2) as SONN
from SH_ORDER_T A
left join PR_DEVICE B on B.ID = A.DEVICEID
where A.SHORDERID = @ShipID
) M
if @SOcou <> 1
  raiserror('All shipped items must be from one sales/internal order.',16,0) 



insert into PDB_BUFFER..SHIPMENT (SESSIONID,OUTDATE,SALESORDER,PRODUCTIONORDER,PARTNUMBER,SN,QUANTITY,DEPID,LOCATION
  ,READYTOSHIPMENT,PICKUPLOCATION)
select @SessionID,GETDATE(),upper(ISNULL(F.ND,D.NN2)),substring(UPPER(isnull(D.NN,'NA')),1,20/*IPM!*/),dbo.PR_NAV_PN_REPLACE(upper(C.CODE),C.REPLACEX),upper(B.SN),isnull(A.QTYTOSHIP,1),@DepID,UPPER(SUBSTRING(isnull(DD.POSTINGCODE,DD.CODE),1,20))
  ,@RS_Date,@RS_Location
from SH_ORDER_T A
left join PR_DEVICE B on B.ID = A.DEVICEID
left join PR_MODELS C on C.ID = B.MODELID
left join PR_PRORDER D on D.ID = B.ORDERID
left join PR_SUPPLY F on F.ID = B.SORDERID
left join SH_ORDER O on O.ID = A.SHORDERID
left join COM_DEPARTMENTS DD on DD.ID = O.DEPID
where A.SHORDERID = @ShipID

declare @DeviceID int
declare nxx cursor local read_only for 
select DEVICEID from SH_ORDER_T where SHORDERID = @ShipID
open nxx 
WHILE 1=1
BEGIN
    FETCH NEXT FROM nxx INTO @DeviceID;
    IF @@FETCH_STATUS<>0 BREAK;
    exec PR_DEVICE_UPD_OPTIONS_SN @DeviceID
END
close nxx;
deallocate nxx;

/*опции (кроме внутренних и предопределенных)*/
insert into PDB_BUFFER..SHIPMENT (SESSIONID,OUTDATE,PRODUCTIONORDER,PARTNUMBER,SN,QUANTITY,DEPID,LOCATION
,READYTOSHIPMENT,PICKUPLOCATION,SALESORDER)
select @SessionID,GETDATE(),substring(UPPER(isnull(D.NN,'NA')),1,10),CC.CODE,C.OPTSN,isnull(C.QUANTITY,1),@DepID,UPPER(SUBSTRING(isnull(DD.POSTINGCODE,DD.CODE),1,20))
,@RS_Date,@RS_Location,upper(ISNULL(F.ND,D.NN2))
from SH_ORDER_T A
left join PR_DEVICE B on B.ID = A.DEVICEID
left join PR_DEVICE_OPT C on C.DEVICEID = A.DEVICEID
left join PR_MODELTYPE_OPTIONS CC on CC.ID = C.OPTID
left join PR_PRORDER D on D.ID = B.ORDERID
left join PR_SUPPLY F on F.ID = B.SORDERID
left join SH_ORDER O on O.ID = A.SHORDERID
left join COM_DEPARTMENTS DD on DD.ID = O.DEPID
where A.SHORDERID = @ShipID
  and isnull(CC.INTOPTION,0) <> 1
  and not exists (select GG.ID from PR_MODEL_OPTIONS GG where GG.MODELID = B.MODELID and GG.OPTIONID = C.OPTID and isnull(GG.PREDEFINEDOPT,0) = 1)
  and C.ID is not null

declare @orderN nvarchar(20)
select top 1 @orderN = A.SALESORDER from PDB_BUFFER..SHIPMENT A where A.SESSIONID = @SessionID

update PDB_BUFFER..SHIPMENT set INTERNALORDER = SALESORDER, SALESORDER = null
where SESSIONID = @SessionID and SALESORDER like 'IO-%'

if (@Remark is not null)
  update PDB_BUFFER..SHIPMENT set ADDINFORMATION = @Remark where SESSIONID = @SessionID

update SH_ORDER set NAVSESSIONUID = @SessionID, NAVSESSIONORDN = @orderN where ID = @ShipID

set nocount off