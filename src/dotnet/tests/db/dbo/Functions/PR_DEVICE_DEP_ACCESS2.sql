create function [dbo].[PR_DEVICE_DEP_ACCESS2](@aOrderDepID int,@aUser int,@aDate datetime)
returns int as 
begin
  return dbo.COM_DEP_ACCESS(null,@aOrderDepID,4,@aUser,@aDate)
end