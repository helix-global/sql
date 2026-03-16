CREATE function [dbo].PR_AC_CONTROLS_TAB (@aUserID int,@aMode int)
returns @res table (ID int)
as 
begin

insert into @res (ID) 
select A.ID from PR_ACTIVECONTROLS A with (nolock) 
where isnull(A.RESTRACCESS,0) = 0

insert into @res (ID) 
select B.ID 
from PR_ACTIVECONTROLS_R A with (nolock) 
left join PR_ACTIVECONTROLS B with (nolock) on B.ID = A.ACID
where A.EMPLID = dbo.DEF_EMPLOYEE(@aUserID)
  and isnull(B.RESTRACCESS,0) = 1
  
if dbo.DEF_USERINGROUP7(@aUserID,'ADM') = 1
begin

	insert into @res (ID) 
	select A.ID from PR_ACTIVECONTROLS A with (nolock) 
	where isnull(A.RESTRACCESS,0) = 1


end


return

end