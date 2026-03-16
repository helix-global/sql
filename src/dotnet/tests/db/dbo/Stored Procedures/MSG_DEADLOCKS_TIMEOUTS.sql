CREATE PROCEDURE [dbo].[MSG_DEADLOCKS_TIMEOUTS] @dd datetime 
AS
BEGIN

/*
create table MSG_DEADLOCKSTIMEOUTS (DD date not null, COU int not null, ONLINECALLS int not null, ONLINECALLTIME_AVG decimal(14,2), ONLINECALLTIME_MAX decimal(14,2))
create unique index IX_MSG_DEADLOCKSTIMEOUTS_DD on MSG_DEADLOCKSTIMEOUTS (DD)
alter table MSG_DEADLOCKSTIMEOUTS add USERSAFFECTED int
alter table MSG_DEADLOCKSTIMEOUTS add OPERATIONSCMPL int
alter table MSG_DEADLOCKSTIMEOUTS add OPER_ISTMELUNG_CMPL int

alter table MSG_DEADLOCKSTIMEOUTS add DO_POSTINGS_LOCKS int

create table MSG_DEADLOCKSTIMEOUTS_ISTM (FORMID int not null primary key)

insert into MSG_DEADLOCKSTIMEOUTS_ISTM (FORMID)
select A.ID 
from PR_OPERATIONS A with (nolock)
where cast(A.FORMXML as nvarchar(max)) like '%LinkGID="4409d92d-09be-4517-9cdc-3a7836dde988"%'

LinkGID="998e7ddd-a2da-4908-bd49-d3782af17bdd"

*/



declare @dbeg datetime = cast(@dd as date)
declare @dend datetime = dateadd(day,1,@dbeg)

declare @locksCou int  
declare @usersAffected int
declare @calls int
declare @callsAvg decimal(14,2)
declare @callsMax decimal(14,2)
declare @opersCmpl int
declare @opersIstmeldungCmpl int
declare @doPostingsLocks int


select @locksCou = count(*)
      ,@usersAffected = count(distinct A.S_USERID)
from DEF_LOG A with (nolock) 
where A.DD >= @dbeg
  and A.DD < @dend
  and A.LEV in (100)
  and A.EV_TYPE = 20002
  and A.DOCOID = 1000039
  and (A.CAPTION like '%(1000023)' or A.CAPTION like '%(1000024)')
  and (A.EV_TEXT like '%deadlock%' or A.EV_TEXT like '%взаимоблокировку%' or A.EV_TEXT like '%imeout%' or A.EV_TEXT like '%истекло%')
  
select @doPostingsLocks  = count(*)
from DEF_LOG A with (nolock) 
where A.DD >= @dbeg
  and A.DD < @dend
  and A.LEV in (100)
  and A.EV_TYPE = 20002
  and A.DOCOID = 1000039
  and (A.CAPTION like '%(1000023)' or A.CAPTION like '%(1000024)')
  and (A.EV_TEXT like '%deadlock%' or A.EV_TEXT like '%взаимоблокировку%' or A.EV_TEXT like '%imeout%' or A.EV_TEXT like '%истекло%')
  and (A.EV_TEXT like '%PR_OPER_DO_POSTINGS%')
  
select @calls = count(*)
      ,@callsAvg = avg(SPENDTIME)
      ,@callsMax = max(SPENDTIME)
from(
select ID
      ,dbo.DEF_LOG_SPENDTIME(cast(A.EV_TEXT as nvarchar(max))) as SPENDTIME
from DEF_LOG A with (nolock) 
where A.DD >= @dbeg
  and A.DD < @dend
  and A.EV_TYPE in (86423,86429)
  and (A.EV_TEXT not like '%GetItemStatus%')
  and (A.EV_TEXT not like '%GetAllowedCustomers%')
  and (A.EV_TEXT not like '%CreateVacation%')
  and (A.EV_TEXT not like '%DeleteVacation%')
  and (A.EV_TEXT not like '%ChangeAbsence%')
  and (A.EV_TEXT not like '%TestCreateInternalOrderXML%')
  and (A.EV_TEXT not like '%GetPartNumber%')
  and (A.EV_TEXT not like '%GetIntOrder%')
  and (A.EV_TEXT not like '%GetOrder%')
  and (A.EV_TEXT not like '%InternalServiceOrder" was not found!%')
) M  


select @opersCmpl = count(*) from PR_OPERATION A with (nolock) 
where A.COMPLETED_DT >= @dbeg and A.COMPLETED_DT < @dend

select @opersIstmeldungCmpl = count(*) from PR_OPERATION A with (nolock) 
where A.COMPLETED_DT >= @dbeg and A.COMPLETED_DT < @dend and A.OPERTYPEID in (select FORMID from MSG_DEADLOCKSTIMEOUTS_ISTM with (nolock))


update MSG_DEADLOCKSTIMEOUTS set COU = @locksCou
  , USERSAFFECTED =  @usersAffected
  , ONLINECALLS = isnull(@calls,0)
  , ONLINECALLTIME_AVG = @callsAvg
  , ONLINECALLTIME_MAX = @callsMax 
  , OPERATIONSCMPL = @opersCmpl
  , OPER_ISTMELUNG_CMPL = @opersIstmeldungCmpl
  , DO_POSTINGS_LOCKS = @doPostingsLocks
  where DD = @dbeg
  
if @@rowcount = 0
begin
   insert into MSG_DEADLOCKSTIMEOUTS ( DD,COU,USERSAFFECTED,ONLINECALLS,ONLINECALLTIME_AVG,ONLINECALLTIME_MAX,OPERATIONSCMPL,OPER_ISTMELUNG_CMPL,DO_POSTINGS_LOCKS)
   values (@dbeg, @locksCou, @usersAffected, isnull(@calls,0), @callsAvg, @callsMax, @opersCmpl, @opersIstmeldungCmpl, @doPostingsLocks)
end 
 
set nocount off
END