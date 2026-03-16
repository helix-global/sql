-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-11-21
-- Description: Returns identifiers list of [PR_REPORT] instances associated with specified revision data.
-- =============================================
-- KB5053:2024-11-21: Initial update.
CREATE function [dbo].[PR_REVISION_ADDEDREPORTS_T](@UserID int,@RevID int,@Options nvarchar(max))
returns @Output table([ID] int, primary key clustered ([ID]))
as
begin
  if @RevID is not null
  begin
    declare @ModelID int
    select top 1
      @ModelID=[rev].[MODELID]
    from [dbo].[PR_REVISION] [rev] with(nolock)
    where [rev].[ID]=@RevID

    insert into @Output
      select distinct
        [rep].[ID]
      from [dbo].[PR_REPORTS] [rep] with(nolock)
      where isnull([rep].[USE_REV_LIST],0)=1
        and ([rep].[S_S] in (1000075))
        and ([rep].[FULLMT]=1
          or exists(select * from [dbo].[PR_REPORTS_T] [b] with(nolock) where [b].[VNESHID]=[rep].[ID] and [b].[REVID]=@RevID)
          or exists(select * from [dbo].[PR_REPORTS_T] [b] with(nolock) where [b].[VNESHID]=[rep].[ID] and [b].[MODELID]=@ModelID))
        and ([rep].[USE_IN_ASSEMBLY] = 1 or [dbo].[COM_IS_SAME_OR_CHILD_DEPARTMENT](@UserID,[rep].[DEPID]) = 1)
    return
  end
  return
end