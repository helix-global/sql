create function dbo.SM_SCALL_IS_SHARED_2_ME(@aCallID int, @aUserID int, @aCaseShareDepID int, @aDate datetime, @aMode int)
returns int as 
begin

  
  if exists (select JH.ID from SM_SERVICE_CALL_SHARE JH with(nolock) where JH.VNESHID = @aCallID and dbo.COM_DEP_ACCESS2(JH.TODEPID,1,@aUserID,@aDate) = 1)
     return 1

  if @aCaseShareDepID is not null and dbo.COM_DEP_ACCESS(null,@aCaseShareDepID,1,@aUserID,@aDate) = 1
     return 1
  
  return 0
end