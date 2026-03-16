CREATE function [dbo].[SW_TOOLS_READONLY] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID)
select A.ID
from SW_TOOLS A with (nolock)
left join SW_TOOL_GROUPS B with (nolock) on B.ID = A.GROUPID
where (A.ACCVIEW = 1 and B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@aDate)))
   or A.ACCVIEW = 2


/*KB2858*/
insert into @res (ID)
select A.ID
from SW_TOOLS A with (nolock)
where A.GROUPID in (select A.VNESHID from SW_GROUP_SHARING_EMPLOYEE A with (nolock)
                     where A.EMPLOYEEID = dbo.DEF_EMPLOYEE(@aUserID)
                    )  

return

end