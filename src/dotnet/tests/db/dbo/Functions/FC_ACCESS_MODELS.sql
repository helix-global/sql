CREATE function [dbo].[FC_ACCESS_MODELS] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin
/* отличается от PR_ACCESS_MODELS тем, что добавлены отделы на которые даны разрешения в FC_DEPSHARING */

declare @deps table (ID int)
insert into @deps (ID)
select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 

/*
insert into @deps (ID)
select A.DEPID 
from FC_DEPSHARING A with (nolock) 
where A.ALLOW2DEPID in (select ID from @deps)
 and (A.ALLOW2EMPLID is null or A.ALLOW2EMPLID = dbo.DEF_EMPLOYEE(@aUserID))
 */

insert into @res (ID) 
select A.ID from PR_MODELS A with (nolock) 
where A.DEPID in (select distinct ID from @deps)

insert into @res (ID) 
select A.ID from PR_MODELS A with (nolock) 
    left join FC_DEPSHARING D with(nolock) on A.DEPID=D.DEPID
    where D.ONLYMTID is null 
        and D.ALLOW2DEPID in (select distinct ID from @deps) and (D.ALLOW2EMPLID is null or D.ALLOW2EMPLID = dbo.DEF_EMPLOYEE(@aUserID))

insert into @res (ID) 
select A.ID from PR_MODELS A with (nolock) 
        left join FC_DEPSHARING D with(nolock) on A.DEPID=D.DEPID
    where A.TYPEID=D.ONLYMTID
        and D.ALLOW2DEPID in (select distinct ID from @deps) and (D.ALLOW2EMPLID is null or D.ALLOW2EMPLID = dbo.DEF_EMPLOYEE(@aUserID))
        and not exists(select ID from FC_DEPSHARING_MODELS where VNESHID = D.ID)

insert into @res (ID) 
select A.ID from PR_MODELS A with (nolock) 
        left join FC_DEPSHARING D with(nolock) on A.DEPID=D.DEPID
        left join FC_DEPSHARING_MODELS M  with(nolock) on A.ID = M.MODELID
    where D.ALLOW2DEPID in (select distinct ID from @deps)  and (D.ALLOW2EMPLID is null or D.ALLOW2EMPLID = dbo.DEF_EMPLOYEE(@aUserID))
        and M.ID is not null

return

end