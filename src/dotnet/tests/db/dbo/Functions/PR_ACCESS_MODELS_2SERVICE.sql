CREATE function [dbo].[PR_ACCESS_MODELS_2SERVICE] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

declare @deps table (ID int)
insert into @deps (ID)
select ID 
from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 

insert into @res (ID) 
select A.ID 
from PR_MODELS A with (nolock) 
left join PR_MODELTYPE B on B.ID = A.TYPEID
where A.DEPID in (select ID from @deps)
   or B.DEPARTMENTID in (select ID from @deps)

insert into @res (ID) 
select A.ID 
from PR_MODELS A with (nolock) 
left join PR_SERVICE_DEPARTMENTS B with (nolock) on B.MTID = A.TYPEID
where B.DEPID in (select ID from @deps)

return

end