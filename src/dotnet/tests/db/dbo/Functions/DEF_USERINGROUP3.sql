CREATE function [dbo].[DEF_USERINGROUP3](@UserID int,@GroupID int)
returns int as
begin
  /* возвращает 1 если пользователь в группе*/
  if @GroupID = 10 /*All*/ 
    return 1

  declare @NowT datetime = getdate()
  declare @NowD date     = @NowT

  if exists (
     select
      [a].[GROUPID]
     from [dbo].[DEF_USERSTOGROUP] [a] with(nolock)
     where ([a].[USERID] = @UserID)
       and ([a].[GROUPID] = @GroupID)
       and ([a].[DCLS] is null or [a].[DCLS] >= @NowD)
      )
  return 1;

/* вложенные группы */
  if exists (select
               [a].[ID]
             from [dbo].[DEF_USERSTOGROUP] [a] with(nolock)
             where ([a].[USERID] = @GroupID)
               and ([a].[DCLS] is null or [a].[DCLS] >= @NowD)
               and ([dbo].[DEF_USERINGROUP](@UserID,[a].[GROUPID],@NowT)=1)
             )
  return 1;
  return 0;
end