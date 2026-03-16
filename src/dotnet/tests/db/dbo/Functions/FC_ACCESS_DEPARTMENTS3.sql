CREATE function [dbo].[FC_ACCESS_DEPARTMENTS3] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID) 
select A.ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) A

insert into @res (ID)
select A.DEPID 
from FC_DEPSHARING A with (nolock) 
where A.ALLOW2DEPID in (select ID from @res)
  and (A.ALLOW2EMPLID is null or A.ALLOW2EMPLID = dbo.DEF_EMPLOYEE(@aUserID))

return

end