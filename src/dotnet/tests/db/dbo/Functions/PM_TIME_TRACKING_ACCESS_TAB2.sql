CREATE function [dbo].[PM_TIME_TRACKING_ACCESS_TAB2] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

/* 
 18.11.2021 PM_TIME_TRACKING_ACCESS_TAB изменено на PM_TIME_TRACKING_ACCESS_TAB2 по KB2789:
  Time Tracking должен быть виден по:
1.       По всем своим задачам (т.е. все свои отчеты)
2.       Всем задачам своего проекта (для руководителя проекта).
3.       Всем своим подзадачам (для тех, кто их может формировать).
4.       Всем задачам, висящим на отделе + по всем дочерним задачам, размещенным в другие отделы (для руководителей отдела).
*/

/*
29.11.2021 +KB2820 
*/

/*
04.04.2022 +KB2974 
*/

declare @emplid int
set @emplid = dbo.DEF_EMPLOYEE(@aUserID)

declare @pd_pm int  /*KB2974 @pd_pm = 1 если у поль-ля роль Projects Designer или Projects Management*/

set @pd_pm = dbo.DEF_USERINGROUP5(@aUserID,'PD','PM',null,null,null)

if dbo.DEF_USERINGROUP1(@aUserID,'DH&VICE') = 1
begin
/*4*/
   insert into @res (ID)
   select A.ID
   from PM_TASK_TIME A with (nolock) 
   left join PM_TASK B with (nolock) on B.ID = A.TASKID
   where B.RESPDEP in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))

   insert into @res (ID)
   select A.ID
   from PM_TASK_TIME A with (nolock) 
   left join PM_TASK B with (nolock) on B.ID = A.TASKID
   where B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
     and B.RESPDEP <> B.DEPID

   /*4  +KB2820  */

   insert into @res (ID)
   select A.ID
   from PM_TASK_TIME A with (nolock) 
   left join PM_TASK B with (nolock) on B.ID = A.TASKID
   left join COM_EMPLOYEE C with (nolock) on C.ID = A.EMPLID
   where C.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
     and B.JIRA_ID is not null
     and not exists (select ID from @res P where P.ID = A.ID)
     and @pd_pm = 1  /*KB2974*/
  
end

/*2*/
insert into @res (ID)
select A.ID
from PM_TASK_TIME A with (nolock) 
left join PM_TASK B with (nolock) on B.ID = A.TASKID
left join PM_PROJECT C with (nolock) on C.ID = B.PROJID
where C.PROJLEAD = @emplid
  and not exists (select ID from @res P where P.ID = A.ID)

insert into @res (ID)
select A.ID
from PM_TASK_TIME A with (nolock) 
left join PM_TASK B with (nolock) on B.ID = A.TASKID
where B.PROJID in (select J.VNESHID from PM_PROJECT_COLEADERS J with (nolock) where J.EMPLID = @emplid)
  and not exists (select ID from @res P where P.ID = A.ID)
   
  
/*3*/
insert into @res (ID)
select A.ID
from PM_TASK_TIME A with (nolock) 
left join PM_TASK B with (nolock) on B.ID = A.TASKID
where B.S_CR = @aUserID
  and not exists (select ID from @res P where P.ID = A.ID)
  and B.JIRA_ID is null  /*KB2820*/
  and @pd_pm = 1  /*KB2974*/
  
  
/*3  +KB2820  */
insert into @res (ID)
select A.ID
from PM_TASK_TIME A with (nolock) 
left join PM_TASK B with (nolock) on B.ID = A.TASKID
where B.RESPDEP in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
  and B.JIRA_ID is not null
  and not exists (select ID from @res P where P.ID = A.ID)
  and @pd_pm = 1  /*KB2974*/

/*3  +KB2820  */
insert into @res (ID)
select A.ID
from PM_TASK_TIME A with (nolock) 
left join PM_TASK B with (nolock) on B.ID = A.TASKID
where B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
 and B.RESPDEP <> B.DEPID
 and B.JIRA_ID is not null
 and not exists (select ID from @res P where P.ID = A.ID)
 and @pd_pm = 1  /*KB2974*/



/*1*/
insert into @res (ID)
select A.ID
from PM_TASK_TIME A with (nolock) 
where A.EMPLID = @emplid
  and not exists (select ID from @res P where P.ID = A.ID)


if dbo.DEF_USERINGROUP5(@aUserID,'ADM','LA',null,null,null) = 1
begin
	insert into @res (ID)
	select A.ID	from PM_TASK_TIME A with (nolock) where not exists (select ID from @res P where P.ID = A.ID)
end

return

end