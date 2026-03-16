CREATE function [dbo].[DEF_F_ACCESS2](@aARC int,@aCR int,@aAction int,@aDate datetime,@aUser int,@aDefault int)
returns int as 
begin
  /*declare @tmp int*/
  /*  версия DEF_F_ACCESS2 отличается от DEF_F_ACCESS отсутствием доступа администратора
      использовать в видимости по отделам 
  select @tmp = A.GROUPID from DEF_USERSTOGROUP A with (nolock)
  where A.USERID = @aUser and A.GROUPID = 8 and (A.DCLS is null or A.DCLS > @aDate);
  if (@tmp = 8)
    return 1;
  
  */

  if (@aUser = @aCR) and (@aAction = 2) return 1;

  if (@aARC is not null)
  begin
    /*set @tmp = null;*/
    declare @tmp int
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
         /*and (B.DCLS is null or B.DCLS >= cast(@aDate as date))*/
         and (select C.S_S from DEF_USERS C with (nolock) where C.ID = B.GROUPID) = 1)
         OPTION (FORCE ORDER)/* Incident# 156987*/
    if (@tmp = 1) return 1 else if (@tmp = 0) return 0;
  end

  return @aDefault;
end