--AZURE06122:2026-01-29: Exclude "SERV-" from processing.
CREATE procedure [dbo].[SH_SHIP2NAVI_COMMON] @ShipID int, @UserID int 
with execute as owner, recompile
as
set nocount on

update [dbo].[SH_ORDER] set
  [NAVSESSIONUID] = null
where [ID] = @ShipID

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

select
   @DepID = [shor].[DEPID]
  ,@NavMode = isnull([shST].[RUNNAVISION],0)
  ,@RS_Req = isnull([shST].[RS_REQUIRED],0)
  ,@RS_Loc_Req = isnull([shST].[RS_LOC_REQUIRED],0)
  ,@RS_Date = [shor].[RS_DATE]
  ,@RS_Time = [shor].[RS_TIME]
  ,@RS_Location = [shor].[RS_LOCATION]
  ,@Remark = [shor].[REMARK]
  ,@SpecialNotes = [shor].[SPNOTES]
  ,@addCheck_AllFrom1IO = isnull([ALL_FROM_ONE_IO],0)
from [dbo].[SH_ORDER] [shor]
  left join [dbo].[SH_SETTINGS] [shST] on [shST].[DEPID] = [shor].[DEPID]
where [shor].[ID] = @ShipID

if (@NavMode <> 1)
begin
  set nocount off
  return
end

if @RS_Req = 1
begin
  if @RS_Date is null or @RS_Time is null
  begin
    raiserror('Please specify "Ready To Shipment" date and time.',16,0)
  end
end

if @RS_Loc_Req = 1 and @RS_Location is null
begin
  raiserror('Please specify shipment pickup location.',16,0)
end

if @RS_Time is not null and @RS_Date is null
begin
  set @RS_Date = getdate()
end

set @RS_Date = cast(cast(@RS_Date as date) as datetime)
if @RS_Time is not null
begin
  set @RS_Date = @RS_Date + cast(cast(@RS_Time as time) as datetime)
end

if @SpecialNotes is not null
begin
  if @Remark is null
  begin
    set @Remark = @SpecialNotes
  end
  else
  begin
    set @Remark = @SpecialNotes + ' ' + isnull(@Remark,'')
  end
end

/*
дополнительная проверка для отделов FBA* (не работают по заказ, плюс оправляют блоки вообще без привязки к MOF, которые они получили из Фрязино
*/
if @addCheck_AllFrom1IO = 1
begin
  declare @errSN nvarchar(50)
  declare @errID int

  select top 1
     @errID = [shoT].[ID]
    ,@errSN = [devi].[SN]
  from [dbo].[SH_ORDER_T] [shoT] with(nolock)
    left join [dbo].[PR_DEVICE] [devi] with(nolock) on [devi].[ID] = [shoT].[DEVICEID]
    left join [dbo].[PR_SUPPLY] [supp] with(nolock) on [supp].[ID] = [devi].[SORDERID]
  where [shoT].[SHORDERID] = @ShipID
     and upper(isnull([supp].[ND],'NONE')) not like 'IO-%'
     and upper(isnull([supp].[ND],'NONE')) not like 'SO-%'
     and upper(isnull([supp].[ND],'NONE')) not like 'IPM-%'
     and upper(isnull([supp].[ND],'NONE')) not like 'SERV-%' --AZURE06122
  /*
    and upper(isnull([dbo].[PR_DEVICE_LAST_ORDER_N]([B].[ID],2),'NONE')) not like 'IO-%' 
    and upper(isnull([dbo].[PR_DEVICE_LAST_ORDER_N]([B].[ID],2),'NONE')) not like 'SO-%' 
    and upper(isnull([dbo].[PR_DEVICE_LAST_ORDER_N]([B].[ID],2),'NONE')) not like 'IPM-%' 
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
select
  @SOcou = count(distinct isnull([SONN],'NA'))
from
  (select [dbo].[PR_DEVICE_LAST_ORDER_N]([devi].[ID],2) as [SONN]
   from [dbo].[SH_ORDER_T] [shoT]
     left join [dbo].[PR_DEVICE] [devi] on [devi].[ID] = [shoT].[DEVICEID]
   where [shoT].[SHORDERID] = @ShipID
  ) [M]
if @SOcou <> 1
  raiserror('All shipped items must be from one sales/internal order.',16,0) 

insert into PDB_BUFFER..SHIPMENT ([SESSIONID],[OUTDATE],[SALESORDER],[PRODUCTIONORDER],[PARTNUMBER],[SN],[QUANTITY],[DEPID],[LOCATION],[READYTOSHIPMENT],[PICKUPLOCATION])
  select
     @SessionID
    ,getdate()
    ,upper(isnull([supp].[ND],[ordP].[NN2]))
    ,substring(upper(isnull([ordP].[NN],'NA')),1,10)
    ,[dbo].[PR_NAV_PN_REPLACE](upper([modl].[CODE]),[modl].[REPLACEX])
    ,upper([devi].[SN])
    ,isnull([shoT].[QTYTOSHIP],1)
    ,@DepID
    ,upper(substring(isnull([dprt].[POSTINGCODE],[dprt].[CODE]),1,20))
    ,@RS_Date
    ,@RS_Location
  from [dbo].[SH_ORDER_T] [shoT]
    left join [dbo].[PR_DEVICE]       [devi] on [devi].[ID] = [shoT].[DEVICEID]
    left join [dbo].[PR_MODELS]       [modl] on [modl].[ID] = [devi].[MODELID]
    left join [dbo].[PR_PRORDER]      [ordP] on [ordP].[ID] = [devi].[ORDERID]
    left join [dbo].[PR_SUPPLY]       [supp] on [supp].[ID] = [devi].[SORDERID]
    left join [dbo].[SH_ORDER]        [shor] on [shor].[ID] = [shoT].[SHORDERID]
    left join [dbo].[COM_DEPARTMENTS] [dprt] on [dprt].[ID] = [shor].[DEPID]
  where [shoT].[SHORDERID] = @ShipID

declare @DeviceID int
declare nxx cursor local read_only for
  select [DEVICEID]
  from [dbo].[SH_ORDER_T]
  where [SHORDERID] = @ShipID
open nxx
while 1=1
begin
    fetch next from nxx into @DeviceID;
    if @@FETCH_STATUS<>0 break;
    exec [PR_DEVICE_UPD_OPTIONS_SN] @DeviceID
end
close nxx;
deallocate nxx;

/*опции (кроме внутренних и предопределенных)*/
insert into PDB_BUFFER..SHIPMENT ([SESSIONID],[OUTDATE],[PRODUCTIONORDER],[PARTNUMBER],[SN],[QUANTITY],[DEPID],[LOCATION],[READYTOSHIPMENT],[PICKUPLOCATION],[SALESORDER])
  select
     @SessionID
    ,getdate()
    ,substring(upper(isnull([ordP].[NN],'NA')),1,10)
    ,[mdTO].[CODE]
    ,[devO].[OPTSN]
    ,isnull([devO].[QUANTITY],1)
    ,@DepID
    ,upper(substring(isnull([dprt].[POSTINGCODE],[dprt].[CODE]),1,20))
    ,@RS_Date
    ,@RS_Location
    ,upper(isnull([supp].[ND],[ordP].[NN2]))
  from [dbo].[SH_ORDER_T] [shoT]
    left join [dbo].[PR_DEVICE]            [devi] on [devi].[ID] = [shoT].[DEVICEID]
    left join [dbo].[PR_DEVICE_OPT]        [devO] on [devO].[DEVICEID] = [shoT].[DEVICEID]
    left join [dbo].[PR_MODELTYPE_OPTIONS] [mdTO] on [mdTO].[ID] = [devO].[OPTID]
    left join [dbo].[PR_PRORDER]           [ordP] on [ordP].[ID] = [devi].[ORDERID]
    left join [dbo].[PR_SUPPLY]            [supp] on [supp].[ID] = [devi].[SORDERID]
    left join [dbo].[SH_ORDER]             [shor] on [shor].[ID] = [shoT].[SHORDERID]
    left join [dbo].[COM_DEPARTMENTS]      [dprt] on [dprt].[ID] = [shor].[DEPID]
  where [shoT].[SHORDERID] = @ShipID
    and isnull([mdTO].[INTOPTION],0) <> 1
    and not exists (select [mdlO].[ID]
                   from [dbo].[PR_MODEL_OPTIONS] [mdlO]
                   where [mdlO].[MODELID] = [devi].[MODELID]
                     and [mdlO].[OPTIONID] = [devO].[OPTID]
                     and isnull([mdlO].[PREDEFINEDOPT],0) = 1)
    and [devO].[ID] is not null

declare @orderN nvarchar(20)
select top 1
  @orderN = [A].[SALESORDER]
from PDB_BUFFER..SHIPMENT [A]
where [A].[SESSIONID] = @SessionID

update PDB_BUFFER..SHIPMENT set
   [INTERNALORDER] = [SALESORDER]
  ,[SALESORDER] = null
where [SESSIONID] = @SessionID
  and [SALESORDER] like 'IO-%'

update PDB_BUFFER..SHIPMENT set
   [INTERNALORDER] = [SALESORDER]
  ,[SALESORDER] = null
where [SESSIONID] = @SessionID
  and upper([SALESORDER]) like 'ZL-%'  /*KB4038*/

if (@Remark is not null)
begin
  update PDB_BUFFER..SHIPMENT set
    [ADDINFORMATION] = @Remark
  where [SESSIONID] = @SessionID
end

update [dbo].[SH_ORDER] set
   [NAVSESSIONUID] = @SessionID
  ,[NAVSESSIONORDN] = @orderN
where [ID] = @ShipID

set nocount off