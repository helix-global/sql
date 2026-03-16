create function [dbo].[PR_ACCESS_OPERGROUPS] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID)
select A.ID 
from PR_OPERATIONS_GR A with (nolock) 
where A.DEPARTMENTID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
union
select A.GROUPID as ID 
from PR_OPERGROUPS_RAW_BYUSER A with (nolock,noexpand) 
where A.USERID = @aUserID 
  and A.DBEG <= cast(@aDate as date) 
  and A.DEND >= cast(@aDate as date)
  
return 

end