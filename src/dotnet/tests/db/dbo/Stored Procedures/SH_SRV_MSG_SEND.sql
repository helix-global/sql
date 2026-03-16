CREATE procedure [dbo].[SH_SRV_MSG_SEND] @ShipID int, @UserID int 
as
set nocount on

declare @DepID int
declare @NavMode int
declare @IsService int
declare @msgModeSrv int
declare @depCode nvarchar(50)
declare @msgSubj nvarchar(1024)
declare @msgToSrv nvarchar(1024)
declare @msgCCSrv nvarchar(1024)
declare @shNN nvarchar(50)
declare @Remark nvarchar(250)
declare @SpecialNotes nvarchar(50)
declare @shCount int
declare @msgCCCustomer nvarchar(500)
declare @shSO nvarchar(max)
declare @sopIPMsns nvarchar(max)

select @DepID = A.DEPID 
      ,@NavMode = ISNULL(B.RUNNAVISION,0)
      ,@IsService = ISNULL(A.ISSERVICE,0)
      ,@msgModeSrv = ISNULL(B.SRVMSGTYPE,0)
      ,@msgToSrv = B.SRVMSGTO
      ,@msgCCSrv = B.SRVMSGCC
      ,@depCode = C.CODE
      ,@shNN = isnull(A.ND,'NA')
      ,@Remark = A.REMARK 
      ,@SpecialNotes = A.SPNOTES
      ,@shCount = (select count(*) from SH_ORDER_T HH where HH.SHORDERID = A.ID)
      ,@shSO = dbo.SH_ORDER_SO(A.ID)
      ,@sopIPMsns = dbo.SH_COMPONENT_FROM_IPM_SNS(A.ID)
from SH_ORDER A 
left join SH_SETTINGS B on B.DEPID = A.DEPID
left join COM_DEPARTMENTS C on C.ID = A.DEPID
where A.ID = @ShipID

if (@IsService <> 1)
begin
  return
end

--select top 1 @msgCCCustomer = SHSC.MSGCC
--from SH_ORDER_T OD 
--left join PR_DEVICE D with (nolock) on D.ID = OD.DEVICEID
--left join SH_ORDER SHO with (nolock) on SHO.ID = OD.SHORDERID
--left join SH_SETTINGS SHS with (nolock) on SHS.DEPID = SHO.DEPID
--left join PR_PRORDER PO with (nolock) on PO.ID = D.ORDERID
--left join PR_SUPPLY SO with (nolock) on SO.ID = D.SORDERID
--left join SH_SETTINGS_TO_CUSTOMER SHSC with (nolock) on SHSC.CUSTOMERID = coalesce(PO.CUSTOMERID,SO.CUSTOMERID) and SHSC.SETTINGSID = SHS.ID
--where OD.SHORDERID = @ShipID
--  and SHSC.ID is not null

if (/*@NavMode <> 1 or*/ (@msgModeSrv = 0))
begin
  set nocount off
  return
end

declare @ord_N nvarchar(50)
select top 1 @ord_N = substring(upper(dbo.PR_DEVICE_LAST_ORDER_N(A.DEVICEID,2)),1,3)
  from SH_ORDER_T A
 where A.SHORDERID = @ShipID

set @msgSubj = @depCode+' Service Shipment Request '+@shNN

declare @UserEMail nvarchar(200)
declare @userName nvarchar(250)
select @UserEMail = B.EMAIL
     , @userName = B.NAME
from DEF_USERS A
left join COM_EMPLOYEE B on B.ID = A.EMPLOYEEID
where A.ID = @UserID

if @UserEMail is not null
begin
  if @msgCCSrv is not null
     set @msgCCSrv = @msgCCSrv+'; '+@UserEMail
  else    
     set @msgCCSrv = @UserEMail
end     

if @msgCCCustomer is not null
begin
  if @msgCCSrv is not null
     set @msgCCSrv = @msgCCSrv+'; '+@msgCCCustomer
  else    
     set @msgCCSrv = @msgCCCustomer
end     

declare @mess nvarchar(max)
set @mess = 'Dear All,<br><br>This message was automatically generated based on the service shipment request '''+@shNN+''''
set @mess = @mess + ' created by the following user: <b>'+@userName+'</b>.<br><br>'
set @mess = @mess + 'Items ('+ltrim(rtrim(str(@shCount)))+'):<br><br>'

declare @sns nvarchar(max)
set @sns = ''

select @sns = @sns + '<b>' + B.SN + '</b> ' + C.NAME + ' (' + C.CODE + ') ' + isnull(F.NAME,'') + ' <a href = "dynamicsnav://ipgl-bu-nap0.ipgphotonics.com:7046/IPGLNAVI2017/IPG%20Laser%20GmbH/runpage?page=5900&$filter=%27Service%20Header%27.%27No.%27%20IS%20%27%40%2A'+isnull(P.NN,'NA')+'%2A%27">'+isnull(P.NN,'NA')+'</a> ' + '<br>' 
from SH_ORDER_T A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_MODELS C with (nolock) on C.ID = B.MODELID
left join PR_PRORDER P with (nolock) on P.ID = B.LASTSRVORDID
left join COM_CUSTOMER F with (nolock) on F.ID = P.CUSTOMERID
where A.SHORDERID = @ShipID

set @mess = @mess + @sns

/*
if @SpecialNotes is not null
begin
   set @mess = @mess + '<br><b>Special Notes:</b><br>'
   set @mess = @mess + @SpecialNotes
end 

if @sopIPMsns is not null
begin
  set @mess = @mess +'<br>Sub-Assembly from IPM items:' + @sopIPMsns 
end

if @shSO is not null
begin
   set @mess = @mess + '<br>Supply Orders:<br>'
   set @mess = @mess + @shSO
end
*/

if @Remark is not null
begin
   set @mess = @mess + '<br><b>Remark:</b><br>'
   set @mess = @mess + @Remark
end

set @mess = @mess + '<br><br>Please do not answer this e-mail.<br>Production Database'

exec MSG_SEND @UserID,@msgToSrv,@msgCCSrv,@msgSubj,@mess 

set nocount off