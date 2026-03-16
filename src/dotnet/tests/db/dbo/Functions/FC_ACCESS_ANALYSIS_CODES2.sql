CREATE function [dbo].[FC_ACCESS_ANALYSIS_CODES2] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin
/* выдает ID типов моделей на которые можно видеть коды анализа */

/*KB1989*/
if dbo.DEF_USERINGROUP7(@aUserID,'KB1989') = 1
begin
  insert into @res (ID) values (15)
  return
end


declare @emplID int
select top 1 @emplID = A.EMPLOYEEID 
from DEF_USERS A with (nolock) 
where A.ID = @aUserID

declare @deps table (ID int)

insert into @deps (ID)
select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 

insert into @res (ID)
select distinct B.TYPEID
from PR_MODELS B with (nolock)
where B.DEPID in (select ID from @deps)


insert into @deps(ID)
select A.DEPID 
from FC_DEPSHARING A with (nolock) 
where A.ALLOW2DEPID in (select ID from @deps)
  and (A.ALLOW2EMPLID is null or A.ALLOW2EMPLID = dbo.DEF_EMPLOYEE(@aUserID))

insert into @deps (ID)
select B.PARENTDEPARTMENT
from FC_DEPSHARING A with (nolock) 
left join COM_DEPARTMENTS B with (nolock) on B.ID = A.DEPID
where A.ALLOW2DEPID in (select ID from @deps)
  and B.PARENTDEPARTMENT is not null
  and A.ALLOW2EMPLID is null

insert into @deps (ID)
select A.DEPID
from FC_FARA_SETTINGS A with (nolock) 
where A.EMPLID = @emplID
  and A.MTID is null
  and A.FACVIEW = 1


insert into @res (ID)
select A.ID
from PR_MODELTYPE A with (nolock)
where A.DEPARTMENTID in (select ID from @deps)

/*KB683 нужно добавить коды от типа модели тех моделей, которые принадлежат отделам, на которые даны разрешения в FC_DEPSHARING
  под текущую задачу сделан упрощенный вариант: берется тип моделей указанный в FC_DEPSHARING, а не ищется через модели*/
insert into @res (ID)
select A.ONLYMTID
from FC_DEPSHARING A with (nolock) 
where A.ALLOW2DEPID in (select ID from @deps)
  and A.ONLYMTID is not null


insert into @res (ID)
select A.MTID
from FC_FARA_SETTINGS A with (nolock) 
where A.EMPLID = @emplID
  and A.MTID is not null
  and A.FACVIEW = 1


return

end