-- KB5383:2025-04-22: Refactoring.
CREATE function [dbo].[PR_MODELS_CAN_PRODUCE](@DepID int)
returns @OutT table([ID] int primary key clustered)
as
begin
  /* список моделей, которые подразделение может запускать в производство в своих заказах*/
  insert into @OutT ([ID])
  select distinct [ID] from
    (
    select [mdl].[ID]
    from [dbo].[PR_MODELS] [mdl] with(nolock)
    where [mdl].[DEPID]=@DepID
      and [mdl].[S_S] in (1000016,1)
    union
      select [shr].[MODELID]
      from [PR_MODEL_SHARINGR] [shr] with(nolock)
      left join [PR_MODELS] [mdl] with(nolock) on [mdl].[ID]=[shr].[MODELID]
      where [mdl].[S_S] in (1000016,1)
        and [shr].[DEPARTMENTID]=@DepID
        and [shr].[RULETYPE]=1 --Production {a2l:\\Link=oid.def_enumeration.1000085}
    ) [a]
  return
end