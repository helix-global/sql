-- KB5328:2025-03-27: Refactoring.
CREATE function [dbo].[DEF_F_ACCESS](@ARC int,@CR int,@Action int,@Date datetime,@User int,@Default int)
returns int as
begin
  if exists (select *
             from [dbo].[DEF_USERSTOGROUP] [u] with(nolock)
             where [u].[USERID] = @User
               and [u].[GROUPID] in (8,4938) -- ("Administrators","IT Supervisor")
               and isnull([u].[DCLS],'40000101') >= cast(@Date as date))
    return 1;

    /*
    if @aUser = 3
      return 1;
      */
    
  /*
  declare @tmp int
  select @tmp = A.GROUPID from DEF_USERSTOGROUP A with (nolock)
  where A.USERID = @aUser and A.GROUPID = 8 and (A.DCLS is null or A.DCLS >= cast(@aDate as date));

  if (@tmp = 8)
    return 1;
*/
  --STD_METHOD_USE
  if (@User = @CR) and (@Action = 2) return 1; -- ALLOW

  if (@ARC is not null)
  begin
    /*set @tmp = null;*/
    declare @AccessResult int
    select
      @AccessResult = max([a].[RES])
    from [dbo].[DEF_ACCESS] [a] with(nolock)
    where [a].[UID] = @User
      and [a].[ARC] = @ARC
      and [a].[ACT] in (1,10,100,@Action) -- (DEF_ABSTRACT_FULL_CONTROL,DEF_REPORT_FULL_CONTROL,DEF_OPERATION_FULL_CONTROL)

         if (@AccessResult = 1) return 1  -- PERMISSION_ALLOW->AllOW
    else if (@AccessResult = 0) return 0; -- PERMISSION_DENY ->DENY

    select
      @AccessResult = max([a].[RES])
    from [dbo].[DEF_ACCESS] [a] with(nolock)
    where [a].[ARC] = @ARC
      and [a].[ACT] in (1,10,100,@Action)  -- (DEF_ABSTRACT_FULL_CONTROL,DEF_REPORT_FULL_CONTROL,DEF_OPERATION_FULL_CONTROL)
      and [a].[UID] in (select 10 union all
                        select [b].[GROUPID]
                        from [dbo].[DEF_USERSTOGROUP] [b] with(nolock)
                        where [b].[USERID] = @User
                          and isnull([b].[DCLS],'40000101')>= cast(@Date as date)
                        /*and (B.DCLS is null or B.DCLS >= cast(@aDate as date))*/
                          and (select [c].[S_S]
                               from [dbo].[DEF_USERS] [c] with(nolock)
                               where [c].[ID] = [b].[GROUPID]) = 1)
                        option (force order)-- Incident# 156987;

         if (@AccessResult = 1) return 1  -- PERMISSION_ALLOW->AllOW
    else if (@AccessResult = 0) return 0; -- PERMISSION_DENY ->DENY
  end

  return @Default;
end