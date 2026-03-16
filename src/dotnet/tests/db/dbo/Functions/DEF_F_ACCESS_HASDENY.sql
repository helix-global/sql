CREATE function [dbo].[DEF_F_ACCESS_HASDENY](@aARC int,@aAction int,@aDate datetime,@aUser int)
returns int as 
begin

/* возвращает 1 если в одной из групп пользователя есть запрет на действие*/
    
    declare @tmp int
    
    select @tmp = min(A.RES) 
    from DEF_ACCESS A with (nolock) 
    where A.ARC = @aARC and A.ACT in (@aAction) and A.UID in
     (select B.GROUPID from DEF_USERSTOGROUP B with (nolock) 
       where B.USERID = @aUser 
         and isnull(B.DCLS,'40000101')>= cast(@aDate as date)
         and (select C.S_S from DEF_USERS C with (nolock) where C.ID = B.GROUPID) = 1);
         
    if @tmp = 0 return 1;
  
    return 0;
    
end