CREATE function [dbo].[PR_MODELTYPE_OPT_VIEW_DEFAULT] (@aUserID int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID)
select ID 
from PR_MODELTYPE_OPTIONS A with(nolock)
where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,8,@aDate))

if dbo.DEF_USER_GID(@aUserID,0) = '0c09f263-6950-4d15-8a5d-186de4c4c6ae'  /*KB2952*/
begin
	insert into @res (ID)
	select ID 
	from PR_MODELTYPE_OPTIONS A with(nolock)
end


return 

end