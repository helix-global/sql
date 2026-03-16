CREATE function [dbo].[PM_TIME_TRACKING_ACCESS_TAB] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

/* 
  1) HEAD&VICE видит все записи сотрудников своего отдела

  2) PM видит все записи по своим  проектам
    
  3) PME (или, проще - все другие польз-ли) - видит свои записи 
  
*/

declare @emplid int
set @emplid = dbo.DEF_EMPLOYEE(@aUserID)


if dbo.DEF_USERINGROUP1(@aUserID,'DH&VICE') = 1
begin

   insert into @res (ID)
   select A.ID
   from PM_TASK_TIME A with (nolock) 
   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
   where B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
  
end

if dbo.DEF_USERINGROUP1(@aUserID,'PM') = 1
begin

   insert into @res (ID)
   select A.ID
   from PM_TASK_TIME A with (nolock) 
   left join PM_TASK B with (nolock) on B.ID = A.TASKID
   where B.PROJID in (select ID from dbo.PM_PROJECTS_ACCESS_TAB(@aUserID,1,@aDate))
  
end

insert into @res (ID)
select A.ID
from PM_TASK_TIME A with (nolock) 
where A.EMPLID = @emplid

return

end