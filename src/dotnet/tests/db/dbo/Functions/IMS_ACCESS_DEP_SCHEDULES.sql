CREATE function [dbo].[IMS_ACCESS_DEP_SCHEDULES] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

if dbo.DEF_USERINGROUP7(@aUserID,'IMSTR') = 1
begin
  insert into @res (ID) 
  select A.ID from COM_DEPARTMENTS A with (nolock)
end
else if dbo.DEF_USERINGROUP7(@aUserID,'IMSFKB3514') = 1
begin
  insert into @res (ID) 
  select A.ID from COM_DEPARTMENTS A with (nolock)
end
else
begin
  insert into @res (ID) 
  select A.ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) A
end

return

end