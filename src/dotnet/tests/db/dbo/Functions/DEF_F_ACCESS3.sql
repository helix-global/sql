create function [dbo].[DEF_F_ACCESS3](@aARC int,@aCR int,@aAction int,@aDate datetime,@aUser int,@aDefault int,@NoCheckAdminRole int )
returns int as 
begin
  /*
    версия 3 позволяет с помощью параметра @NoCheckAdminRole = 1 
    отключать проверку прав администратора (переключать на режим как у DEF_F_ACCESS2)
  */

  if isnull(@NoCheckAdminRole,0) <> 1
  begin
    if exists (select * from DEF_USERSTOGROUP A with (nolock)
    where A.USERID = @aUser and A.GROUPID in (8,4938) and isnull(A.DCLS,'40000101') >= cast(@aDate as date))
      return 1;
  end    

  if (@aUser = @aCR) and (@aAction = 2) return 1;

  if (@aARC is not null)
  begin
    declare @tmp int
    select @tmp = MAX(A.RES) 
    from DEF_ACCESS A with (nolock)  
    where A.UID = @aUser and A.ARC = @aARC and A.ACT in (1,10,100,@aAction);
    if (@tmp = 1) return 1 else if (@tmp = 0) return 0;
    
    select @tmp = MAX(A.RES) 
    from DEF_ACCESS A with (nolock) 
    where A.ARC = @aARC and A.ACT in (1,10,100,@aAction) and A.UID in
     (select 10 union all select B.GROUPID from DEF_USERSTOGROUP B with (nolock) 
       where B.USERID = @aUser 
         and isnull(B.DCLS,'40000101')>= cast(@aDate as date)
         and (select C.S_S from DEF_USERS C with (nolock) where C.ID = B.GROUPID) = 1);
    if (@tmp = 1) return 1 else if (@tmp = 0) return 0;
  end

  return @aDefault;
end