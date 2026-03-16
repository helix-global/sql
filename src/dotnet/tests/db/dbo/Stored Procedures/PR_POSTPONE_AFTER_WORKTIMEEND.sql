CREATE procedure [dbo].[PR_POSTPONE_AFTER_WORKTIMEEND]  @UserID int, @aMode int
as 

SET nocount on

declare @now datetime = getdate()

if datepart(hour,@now) >= 19 and datepart(hour,@now) <= 21
begin
   exec DEF_LOG_ADDINFO 'debug PR_POSTPONE_AFTER_WORKTIMEEND execution', null, null 
end

declare @depsToPostpone table (ID int not null)

insert into @depsToPostpone (ID)
select A.ID
from COM_DEPARTMENTS A with (nolock) 
where A.AUTOPOSTPONEOPERTTIME is not null
  and dbo.PR_NEEDAUTOPOSTPONE2(A.AUTOPOSTPONEOPERTTIME,@now) = 1

if @@rowcount = 0
  return

exec DEF_LOG_ADDINFO 'debug PR_POSTPONE_AFTER_WORKTIMEEND has departments', null, null 

declare @opersToPostpone table (ID int not null,USERINPROGRESS int,EMPLID int)

insert into @opersToPostpone (ID,USERINPROGRESS,EMPLID)
select A.ID, A.USERINPROGRESS, U.EMPLOYEEID 
from PR_OPERATION A with (nolock)
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
left join DEF_USERS U with (nolock) on U.ID = A.USERINPROGRESS
where A.S_S = 1000031 /*in progress*/
  and A.ORDERID is not null
  and B.DEPARTMENTID in (select J.ID from @depsToPostpone J)


/*KB638 added preparatory operations */
insert into @opersToPostpone (ID,USERINPROGRESS,EMPLID)
select A.ID, A.USERINPROGRESS, U.EMPLOYEEID 
from PR_OPERATION A with (nolock)
left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
left join DEF_USERS U with (nolock) on U.ID = A.USERINPROGRESS
where A.S_S = 1000031 /*in progress*/
  and A.ORDERID is null
  and A.DEVICEID is null
  and B.DEPID in (select J.ID from @depsToPostpone J)


/*убрать (не переводить в postpone) там, где у пользователя есть переработка на этот момент */
delete from @opersToPostpone 
where EMPLID is not null
  and exists (select K.ID from COM_ADDED_WORKTIME K with (nolock) 
               where K.EMPLID = "@opersToPostpone".EMPLID 
                 and K.DBEG <= @now
                 and K.DEND > @now
             )    
             
insert into PR_AUTOPOSTPONE_HISTORY (OPERID, DD)             
select ID,getdate() from @opersToPostpone

update PR_OPERATION_TIME set DEND = getdate() 
where OPERID in (select J.ID from @opersToPostpone J)
  and DEND is null

update PR_OPERATION set S_S = 1000033 /*postponed*/
where ID in (select J.ID from @opersToPostpone J)
   
  
SET nocount off