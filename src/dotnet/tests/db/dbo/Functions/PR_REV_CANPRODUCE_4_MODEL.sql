-- =============================================
-- Author:      Dmitry Norkin
-- Create date: 2015-04-10
-- Description: Returns the list of revisions that a department can produce on its orders for a model.
-- =============================================
-- KB5383:2025-04-23: Refactoring. Added "other revisions if the model is can be produced by department" condition.
CREATE function [dbo].[PR_REV_CANPRODUCE_4_MODEL](@ModelID int,@DepID int)
returns @OutT table([ID] int primary key clustered)
as
begin
  --#region {ownself revisions}
  insert into @OutT ([ID])
    select distinct [rev].[ID]
    from [dbo].[PR_REVISION] [rev] with(nolock)
      left join [dbo].[PR_MODELS] [mdl] with(nolock) on [mdl].[ID]=[rev].[MODELID]
    where [mdl].[DEPID]=@DepID
      and [rev].[MODELID]=@ModelID
      and [rev].[S_S] in (1000017) /*approved*/
  --#endregion
  --#region {other revisions if the model is inherited with permission from the owner department}
  declare @ParentModelID int
  select
    @ParentModelID = [mdl].[PARENTMODELID]
  from [PR_MODELS] [mdl] with(nolock)
  where [mdl].[ID] = @ModelID

  if @ParentModelID is not null
  begin
    merge @OutT [a]
    using
      (
      select distinct [rev].[ID]
      from [PR_REVISION] [rev] with(nolock)
        left join [PR_MODELS] [mdl] with(nolock) on [mdl].[ID]=[rev].[MODELID]
      where [rev].[MODELID] = @ParentModelID
        and [rev].[S_S] in (1000017) /*approved*/
        and [mdl].[DEPID] <> @DepID
        and exists (select [shr].[ID]
                    from [dbo].[PR_MODEL_SHARINGR] [shr] with(nolock)
                    where [shr].[MODELID]=[rev].[MODELID]
                      and [shr].[DEPARTMENTID]=@DepID
                      and [shr].[RULETYPE]=1)
      ) [b] on [a].[ID]=[b].[ID]
    when not matched then
      insert ([ID]) values ([b].[ID]);
  end
  --#endregion
  --#region {other revisions if the model is can be produced by department}
  merge @OutT [a]
  using
    (
    select distinct [rev].[ID]
    from [PR_REVISION] [rev] with(nolock)
      left join [PR_MODELS] [mdl] with(nolock) on [mdl].[ID]=[rev].[MODELID]
    where [rev].[MODELID]=@ModelID
      and [rev].[S_S] in (1000017) /*approved*/
      and [mdl].[DEPID] <> @DepID
      and exists (select [shr].[ID]
                  from [dbo].[PR_MODEL_SHARINGR] [shr] with(nolock)
                  where [shr].[MODELID]=[rev].[MODELID]
                    and [shr].[DEPARTMENTID]=@DepID
                    and [shr].[RULETYPE]=1)
    ) [b] on [a].[ID]=[b].[ID]
  when not matched then
    insert ([ID]) values ([b].[ID]);
  --#endregion
  return
end