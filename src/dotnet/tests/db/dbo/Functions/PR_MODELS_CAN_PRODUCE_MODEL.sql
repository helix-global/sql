-- KB5383:2025-04-22: Initial Update.
CREATE function [dbo].[PR_MODELS_CAN_PRODUCE_MODEL](@UserID int,@ModelID int)
returns int
as
begin
  if @ModelID=0 or @ModelID is null return 0
  if @UserID=0  or @UserID is null  return 0

  declare @UserDepID  int
  select top 1
    @UserDepID=[e].[DEPID]
  from [dbo].[DEF_USERS] [u] with(nolock)
    inner join [dbo].[COM_EMPLOYEE] [e] with(nolock) on [e].[ID]=[u].[EMPLOYEEID]
  where [u].[ID]=@UserID

  declare @DepT table([DEPID] int primary key clustered)
  insert into @DepT
    select distinct [a].[DEPID] from
      (
      select top 1 [mdl].[DEPID]
      from [dbo].[PR_MODELS] [mdl] with(nolock)
      where [mdl].[ID]=@ModelID
      union all
        select [shr].[DEPARTMENTID]
        from [PR_MODEL_SHARINGR] [shr] with(nolock)
        where [shr].[MODELID]=@ModelID
          and [shr].[RULETYPE]=1 --Production {a2l:\\Link=oid.def_enumeration.1000085}
      ) [a]

  if exists(select * from @DepT [dep] where [dep].[DEPID]=@UserDepID)
  begin
    return 1
  end

  return 0
end