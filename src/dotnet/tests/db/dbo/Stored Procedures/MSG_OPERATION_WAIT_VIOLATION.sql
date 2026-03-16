CREATE PROCEDURE [dbo].[MSG_OPERATION_WAIT_VIOLATION] @aUserID int
AS
BEGIN
/*KB3900*/
set nocount on
declare @now datetime
set @now = GETDATE()   
  
declare @opers table (OPERID int, DEVICEID int, ORDERID int, OPERFORMID int, DEPID int, WAITLIMIT int, NOWWAIT int)

declare @depIDs table (ID int)
insert into @depIDs (ID)
select distinct A.DEPID
from MSG_DELIVERYLIST A with(nolock)
where A.DELIVERYTYPE = 2410 /*Notification about violation of the Operation Wait Limit time*/

if not exists (select ID from @depIDs)
begin
  set nocount off
  return 
end


insert into @opers (OPERID,DEVICEID,ORDERID,OPERFORMID,DEPID,WAITLIMIT,NOWWAIT)

select A.ID
     , B.ID
     , F.ID
     , A.OPERTYPEID
     , F.DEPARTMENTID
	 , coalesce(LL.WAITNORM,C.WAITNORM) 
	 , dbo.PR_OPERATION_STAT(A.ID, 14, @now)
from PR_OPERATION A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_MAP_OPER C with (nolock) on C.ID = A.REVOPERID
left join PR_PRORDER F with (nolock) on F.ID = A.ORDERID
left join PR_REV_OVER_WAITNORM LL with(nolock) on LL.REVID = B.REVID and LL.MAPOPERID = C.ID
where A.S_S in (1000032,1000033) /*pending,postponed*/
  and A.COMPLETED_DT is null
  and A.ORDERID is not null
  and coalesce(LL.WAITNORM,C.WAITNORM) > 0
  and dbo.PR_OPERATION_STAT(A.ID, 14, @now) > coalesce(LL.WAITNORM,C.WAITNORM)
  and not exists (select KK.OPERID from MSG_OPER_WAITWASNOTIFIED KK with (nolock) where KK.OPERID = A.ID)
  and F.DEPARTMENTID in (select ID from @depIDs)
  and A.OPERTYPEID is not null
  and B.ID is not null
  and B.S_S not in (1000101)  /*canceled*/

if not exists (select OPERID from @opers)
begin
  set nocount off
  return 
end

insert into MSG_OPER_WAITWASNOTIFIED (OPERID)
select distinct OPERID from @opers

declare @depid int
declare nxx cursor local read_only for 
select distinct DEPID from @opers
open nxx 
WHILE 1=1
BEGIN
    FETCH NEXT FROM nxx INTO @depid;
    IF @@FETCH_STATUS<>0 BREAK;
    
    declare @ex int = 0

    declare @mess nvarchar(max)
    set @mess = 'Dear All,<br><br>The beginning of the following operations take too much time:<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
    set @mess = @mess + '<tr><th>Model</th><th>SN</th><th>Order</th><th>Operation</th><th>Wait limit</th><th>Time of waiting</th><th> </th></tr>'
    
    select @ex = 1
      , @mess = @mess + '<tr><td>'+C.CODE+'</td><td>'+B.SN+'</td><td>'+isnull(D.NN,'NA')+'</td><td>'+isnull(E.NAME,'NA')+'</td><td>'+
      isnull(cast(A.WAITLIMIT as nvarchar(20)),'NA')+'m</td><td>'+isnull(cast(A.NOWWAIT as nvarchar(50)),'NA')+'m</td>'+
      '<td><a href = "a2l:\\Link=doc.pr_device_operation.'+LTRIM(rtrim(str(A.OPERID)))+'">open</a></td></tr>'
    from @opers A 
    left join PR_DEVICE B with(nolock) on B.ID = A.DEVICEID
    left join PR_MODELS C with(nolock) on C.ID = B.MODELID
    left join PR_PRORDER D with(nolock) on D.ID = A.ORDERID
    left join PR_OPERATIONS E with(nolock) on E.ID = A.OPERFORMID
    where A.DEPID = @depid


    set @mess = @mess + '</table></font><br><br>Please, do not answer this e-mail.<br>Production Database'

    if @ex = 1
    begin
		exec MSG_SEND_TODELIVERYGROUP4 @aUserID, 2410, @depid, 'Violation of the Operation Wait Limit time',@mess, null
	end

    
END
close nxx;
deallocate nxx;

  
set nocount off
END