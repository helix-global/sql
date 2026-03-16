create function [dbo].[test_DEF_F_ACCESS](@aARC int,@aCR int,@aAction int,@aDate datetime,@aUser int,@aDefault int)
returns int as 
begin

  if exists (select * from DEF_USERSTOGROUP A with (nolock)
  where A.USERID = @aUser and A.GROUPID = 8 and isnull(A.DCLS,'40000101') >= cast(@aDate as date))
    return 1;

  if (@aUser = @aCR) and (@aAction = 2) return 1;

  if (@aARC is not null)
  begin
    declare @tmp int = null;
    select @tmp = MAX(A.RES) 
    from DEF_ACCESS A  with (nolock)  
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

  
  if exists (select * from DEF_USERSTOGROUP A with (nolock)
  where A.USERID = @aUser and A.GROUPID = 9 and isnull(A.DCLS,'40000101') >= cast(@aDate as date))
    return 1;

  return @aDefault;
end