CREATE function [dbo].[SW_ACCESS_GROUPS] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

declare @deps table (ID int)
insert into @deps (ID)
select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 

insert into @deps (ID)
select A.DEPID 
from FC_DEPSHARING A with (nolock) 
where A.ALLOW2DEPID in (select ID from @deps)

insert into @res (ID) 
select A.ID from SW_TOOL_GROUPS A with (nolock) 
where (A.DEPID in (select distinct ID from @deps)
       or isnull(A.SHARETOALL,0) = 1
       or exists(select G.ID 
			   from SW_GROUP_SHARING G with (nolock) 
			  where G.VNESHID = A.ID 
				and G.DEPARTMENTID in (select distinct ID from @deps))
		)
		or exists (select G.ID 
			   from SW_GROUP_SHARING_EMPLOYEE G with (nolock) 
			  where G.VNESHID = A.ID 
				and G.EMPLOYEEID = dbo.DEF_EMPLOYEE(@aUserID) ) 
  and (not exists (select J.ID from PR_DOC_SETTINGS J where J.SWGROUP = A.ID) /*группы Declarations of Conformity (внесенные в pr_doc_settings)должны видеть либо ownerы либо члены роли 'SWDoC' */
       or dbo.DEF_USERINGROUP7(@aUserID,'SWDoC') = 1
       or A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
       )
  		

return

end