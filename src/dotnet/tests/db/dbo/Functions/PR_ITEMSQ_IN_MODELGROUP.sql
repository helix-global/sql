CREATE function [dbo].[PR_ITEMSQ_IN_MODELGROUP](@ModelGroupID int)
returns int as
begin
  declare @RetVal int
  select @RetVal = count([dev].[ID])
  from [dbo].[PR_DEVICE] [dev] with(nolock)
    inner join [dbo].[PR_REVISION] [rev] with(nolock,index([IX_PR_REVISION_MODELID_ID_MODELGROUPID])) on [rev].[ID]=[dev].[REVID]
    inner join [dbo].[PR_MODELS]   [mdl] with(nolock,index([IX_PR_MODELS_ID_MODELGROUPID]))           on [mdl].[ID]=[rev].[MODELID]
  where isnull([rev].[MODELGROUPID],[mdl].[MODELGROUPID]) = @ModelGroupID
  return @RetVal
end