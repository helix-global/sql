CREATE PROCEDURE [dbo].[MSG_FAILURE_REPORTED] 
AS
BEGIN
set nocount on
declare @now datetime
set @now = GETDATE()   
declare @now_1min datetime
set @now_1min = DATEADD(minute,-1,@now)
  
declare @opers table (OPERID int, DEPID int, MESS nvarchar(max))

insert into @opers (OPERID,DEPID)
select A.ID,B.DEPARTMENTID
from PR_OPERATION A with (nolock)
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
where A.ID > 800000/*1353622*/
  and A.S_S = 1000018 /*Failure*/
  and A.S_MDT < @now_1min
  and cast(A.S_MDT as date) = cast(@now as date)

if not exists (select OPERID from @opers)
begin
  set nocount off
  return 
end

declare @NotifyUsers table (DEPID int, USERID int)
insert into @NotifyUsers (DEPID,USERID)
select B.ID, A.ID
from dbo.DEF_USERSINGROUP2('SPV_NOTY2') A
cross apply dbo.COM_ACCESS_DEPARTMENTS(A.ID,1,@now) B
where B.ID in (select G.DEPID from @opers G)
  

if not exists (select USERID from @NotifyUsers)
begin
  set nocount off
  return 
end

update @opers set MESS = dbo.MSG_OPERATION_FAILURE_TEXT(OPERID)

declare @Msgs table (OPERID int,USERID int,MESS nvarchar(max))
insert into @Msgs (OPERID,USERID,MESS)
select A.OPERID, B.USERID, A.MESS
from @opers A
left join @NotifyUsers B on B.DEPID = A.DEPID
where not exists (select H.OPERID from MSG_FAILURE_WASNOTIFIED H where H.OPERID = A.OPERID and H.USERID = B.USERID)


insert into MSG_FAILURE_WASNOTIFIED (OPERID, USERID)
select distinct A.OPERID, A.USERID
from @Msgs A 
where not exists (select H.OPERID from MSG_FAILURE_WASNOTIFIED H where H.OPERID = A.OPERID and H.USERID = A.USERID)
  and A.OPERID is not null
  and A.USERID is not null


declare @userid int
declare nxx cursor local read_only for 
select distinct USERID from @Msgs
open nxx 
WHILE 1=1
BEGIN
    FETCH NEXT FROM nxx INTO @userid;
    IF @@FETCH_STATUS<>0 BREAK;

    declare @mess nvarchar(max)
    set @mess = 'Dear All,<br><br>By the following operations was reported failure:<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
    set @mess = @mess + '<tr><th>SN</th><th>Order</th><th>Operation</th><th>Failure</th><th>Employee</th><th> </th></tr>'
    
    select @mess = @mess + A.MESS
    from @Msgs A where A.USERID = @userid

    set @mess = @mess + '</table></font><br><br>Please, do not answer this e-mail.<br>Production Database'

    exec MSG_SEND_TOUSER 0,@userid,'Failure operation reported',@mess
    
END
close nxx;
deallocate nxx;

  
set nocount off
END