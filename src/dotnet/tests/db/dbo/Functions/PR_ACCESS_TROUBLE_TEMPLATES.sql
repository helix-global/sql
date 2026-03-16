create function dbo.PR_ACCESS_TROUBLE_TEMPLATES (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID)
select A.ID 
from PR_TROUBLE_TEMPLATES A with (nolock) 
where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
  and (isnull(A.SHARETO,0) = 1 or A.S_CR = @aUserID)
  
return 

end