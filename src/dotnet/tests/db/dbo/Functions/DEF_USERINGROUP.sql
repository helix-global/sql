CREATE function [dbo].[DEF_USERINGROUP](@UserID int,@GroupID int,@Date datetime)
returns int as 
begin
  if @GroupID = 10 /*All*/
    return 1

  declare @DateD date = @Date
  declare @OtherGroupID int
  select
    @OtherGroupID = [a].[GROUPID]
  from [dbo].[DEF_USERSTOGROUP] [a] with(nolock)
  where ([a].[USERID] = @UserID)
    and ([a].[GROUPID] = @GroupID)
    and ([a].[DCLS] is null or [a].[DCLS] >= @DateD);

  if (@OtherGroupID = @GroupID) return 1;
  if exists (select [a].[ID]
             from [dbo].[DEF_USERSTOGROUP] [a] with(nolock)
             where ([a].[USERID] = @GroupID)
               and ([a].[DCLS] is null or [a].[DCLS] >= @DateD)
               and ([dbo].[DEF_USERINGROUP](@UserID,[a].[GROUPID],@Date) = 1)
             )
  return 1;
  return 0;
end