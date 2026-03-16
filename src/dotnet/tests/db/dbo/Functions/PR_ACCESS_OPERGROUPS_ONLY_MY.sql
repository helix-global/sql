
create function [dbo].[PR_ACCESS_OPERGROUPS_ONLY_MY] (@aUserID int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID)
select A.GROUPID 
from PR_OPERGROUPS_RAW_BYUSER A with (nolock,noexpand) 
where A.USERID = @aUserID 
  and A.DBEG <= cast(@aDate as date) 
  and A.DEND >= cast(@aDate as date)

return 

end