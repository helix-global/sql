CREATE function [dbo].SL_CHECK_DEP_IN_CHANGES(@aDepID int, @aUserID int, @aMode int)
returns int
as
begin

  if dbo.DEF_USERINGROUP7(@aUserID,'SL_APPROVE') = 1
    return 1

  if dbo.COM_DEP_ACCESS(null,@aDepID,1,@aUserID,getdate()) = 1
     return 1
  
  return 0
  
end;