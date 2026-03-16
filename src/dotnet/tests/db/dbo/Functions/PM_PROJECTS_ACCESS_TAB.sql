CREATE function [dbo].[PM_PROJECTS_ACCESS_TAB] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

/* 

  1) если пользователь в группе PM, то видит свои проекты
  2) если пользователь в группе Dep.Head, то видит все проекты отдела
  
  
*/

declare @emplid int
set @emplid = dbo.DEF_EMPLOYEE(@aUserID)


if dbo.DEF_USERINGROUP1(@aUserID,'PM') = 1
begin

   insert into @res (ID)
   select A.ID
   from PM_PROJECT A with (nolock)
   where A.PROJLEAD = @emplid
   
   insert into @res (ID)
   select A.VNESHID
   from PM_PROJECT_COLEADERS A with (nolock)
   where A.EMPLID = @emplid
   
   if @aUserID = 1179 /*временно на основании письма даны права на проекты, такие как у начальника отдела*/
   begin
     insert into @res (ID) 
     select A.ID from PM_PROJECT A with (nolock) where A.DEPID = 182 /*R&D-PL*/
   end  
  
end

if dbo.DEF_USERINGROUP1(@aUserID,'DH&VICE') = 1
begin

   insert into @res (ID)
   select A.ID
   from PM_PROJECT A with (nolock)
   where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
   
   if @aMode = 10 /*KB1781*/
   begin
	   insert into @res (ID)
	   select distinct A.PROJID
	   from PM_TASK A with (nolock)
	   where A.RESPDEP in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
   end
   
end

if dbo.DEF_USERINGROUP1(@aUserID,'ADM') = 1
begin

   insert into @res (ID)
   select A.ID
   from PM_PROJECT A with (nolock)
   
end

/* KB4858 pojects where user is in COLEADERS by Project (12.07.2024 MEfimov) */
insert into @res (ID)
select PMPC.VNESHID
from PM_PROJECT_COLEADERS PMPC with (nolock) 
left join DEF_USERS U with (nolock) on U.EMPLOYEEID = PMPC.EMPLID
where U.ID = @aUserID
/* KB4858 pojects where user is in COLEADERS by Project (12.07.2024 MEfimov) */



--insert into @res (ID)
--   select A.ID
--   from PM_PROJECT A with (nolock)
--   where S_CR=@aUserID

/*01.01.2020 KB1781 add видимость проекта для исполнителя*/
/*KB4605 - отключить такую возможность*/
/*
insert into @res (ID)
select distinct C.ID
from PM_TASK_ASSIGNEE A with (nolock)
left join PM_TASK B with (nolock) on B.ID = A.VNESHID
left join PM_PROJECT C with (nolock) on C.ID = B.PROJID
where A.EMPLID = @emplid
  and C.S_S in (2130048 /*active*/)
*/


return

end