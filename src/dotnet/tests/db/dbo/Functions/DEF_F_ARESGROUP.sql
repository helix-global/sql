CREATE function [dbo].[DEF_F_ARESGROUP](@aARC int,@aCR int,@aAction int,@aDate datetime,@aUser int)
returns int as 
begin
  /*
  возвращает группу на основании которой выдан результат dbo.DEF_F_ACCESS
  группы берутся по приоритету в GRGRADE 
  ищется группа с минимальным значением GRGRADE
  */

  if exists (select * from DEF_USERSTOGROUP A with (nolock)
  where A.USERID = @aUser and A.GROUPID in (8,4938) and isnull(A.DCLS,'40000101') >= cast(@aDate as date))
    return -50;  /*админ*/

  if (@aUser = @aCR) and (@aAction = 2) 
    return -100;  /*автор*/

  if (@aARC is not null)
  begin
    declare @tmp int
    
    select @tmp = MAX(A.RES) 
    from DEF_ACCESS A  with (nolock)  
    where A.UID = @aUser and A.ARC = @aARC and A.ACT in (1,10,100,@aAction);
    if (@tmp = 1) 
       return -200  /*личные права*/ 
    else if (@tmp = 0) 
       return -200  /*личные права*/ 

    declare @tmpGroup int
    
    select top 1 @tmp = A.RES, @tmpGroup = A.UID 
    from DEF_ACCESS A with (nolock) 
    left join DEF_USERS J with (nolock) on J.ID = A.UID and J.ISGROUP = 1 
    where A.ARC = @aARC and A.ACT in (1,10,100,@aAction) and A.UID in
     (select 10 union all select B.GROUPID from DEF_USERSTOGROUP B with (nolock) 
       where B.USERID = @aUser 
         and isnull(B.DCLS,'40000101')>= cast(@aDate as date)
         and (select C.S_S from DEF_USERS C with (nolock) where C.ID = B.GROUPID) = 1)
     order by A.RES desc, J.GRGRADE    
         
         
    if (@tmp = 1) 
      return @tmpGroup 
    else if (@tmp = 0) 
      return @tmpGroup
    
  end

  return null;
end