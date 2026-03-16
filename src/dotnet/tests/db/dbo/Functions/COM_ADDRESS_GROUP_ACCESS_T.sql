create function [dbo].[COM_ADDRESS_GROUP_ACCESS_T] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID) 
select A.ID from COM_MANAGED_ADDR_GROUPS A with (nolock) 
where A.S_CR = @aUserID


insert into @res (ID) 
select A.ID from COM_MANAGED_ADDR_GROUPS A with (nolock) 
left join DEF_USERS B with (nolock) on B.ID = A.S_CR
left join COM_EMPLOYEE C with (nolock) on C.ID = B.EMPLOYEEID
where A.SHARETYPE = 1
  and dbo.COM_DEP_ACCESS2(C.DEPID,@aMode,@aUserID,@aDate) = 1 


return

end