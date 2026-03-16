CREATE function [dbo].[IMS_ACCESS_DEP_SCHEDULES2] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

if dbo.DEF_USERINGROUP7(@aUserID,'IMSTR') = 1
begin
  insert into @res (ID) 
  select A.ID
  from IMS_DEP_SCHEDULE A with (nolock) 
  where A.SCHEDULEID in (select ID from dbo.IMS_ACCESS_SCHEDULES(@aUserID,@aMode,@aDate))
end
else if dbo.DEF_USERINGROUP7(@aUserID,'IMSFKB3514') = 1
begin
  insert into @res (ID) 
  select A.ID
  from IMS_DEP_SCHEDULE A with (nolock) 
  where A.SCHEDULEID in (select ID from dbo.IMS_ACCESS_SCHEDULES(@aUserID,@aMode,@aDate))
end
else
begin
  insert into @res (ID) 
  select A.ID 
  from IMS_DEP_SCHEDULE A with (nolock) 
  where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate))
end

return

end