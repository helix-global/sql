CREATE function [dbo].[SM_SCASE_ACCESS](@aScaseID int, @aUserID int,@aServDepID int,@aShareDepID int, @aDate datetime, @aMode int)
returns int as 
begin

  
  if dbo.COM_DEP_ACCESS(null,@aServDepID,1,@aUserID,@aDate) = 1
     return 1

  if @aShareDepID is not null and dbo.COM_DEP_ACCESS(null,@aShareDepID,1,@aUserID,@aDate) = 1
     return 1
  
  return 0
end