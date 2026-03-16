CREATE function [dbo].[PM_DEV_PLAN_ACCESS_TAB] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin


declare @emplid int
set @emplid = dbo.DEF_EMPLOYEE(@aUserID)


if dbo.DEF_USERINGROUP1(@aUserID,'PME') = 1
begin

   insert into @res (ID)
   select A.ID
   from PM_DEV_PLAN A with (nolock)
   where A.EMPLID = @emplid
  
end

if dbo.DEF_USERINGROUP1(@aUserID,'DH&VICE') = 1
begin

   insert into @res (ID)
   select A.ID
   from PM_DEV_PLAN A with (nolock)
   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
   where B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
     and A.S_S in (2130056,2130057,2130058 /*KB3198*/,2130059/*deprecated*/)
     
   insert into @res (ID)
   select A.ID
   from PM_DEV_PLAN A with (nolock)
   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
   where B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
     and A.S_S in (1)
     and A.S_CR = @aUserID
     
      
end

if dbo.DEF_USERINGROUP1(@aUserID,'ADM') = 1
begin
   insert into @res (ID)
   select A.ID
   from PM_DEV_PLAN A with (nolock)
end


return

end