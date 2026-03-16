-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-01-26
-- Description: Returns identifiers of [PR_REPORT] instances associated with specified preparatory operation.
-- =============================================
-- KB4488:2024-01-26: Initial update.
CREATE function [dbo].[PR_OP_PRE_REPORTS](@OperId int)
returns @Identifiers table ([ID] int,unique clustered ([ID]))
as
begin
  declare @PreOperModelTypeId int
  declare @OperTypeId int
  select
     @PreOperModelTypeId=[p].[TYPEID]
    ,@OperTypeId=[o].[OPERTYPEID]
  from [dbo].[PR_PREPARATORY] [p] with(nolock)
    inner join [dbo].[PR_OPERATIONS] [O] with(nolock) on [O].[ID]=[p].[OPERID]
    inner join [dbo].[PR_OPERATION]  [o] with(nolock) on [o].[OPERTYPEID]=[O].[ID]
  where [o].[ID]=@OperId

  merge @Identifiers [i]
  using
    (
    select [a].[ID]
    from [dbo].[PR_REPORTS] [a] with(nolock)
    where ([a].[S_S] = 1000075)
      and ([a].[USE_OPER_ONE]=@OperTypeId)
    ) [a] on [i].[ID]=[a].[ID]
  when not matched then
    insert ([ID]) values ([a].[ID]);

  merge @Identifiers [i]
  using
    (
    select [a].[ID]
    from [dbo].[PR_REPORTS] [a] with(nolock)
    where ([a].[S_S] = 1000075)
      and ([a].[MTID] = @PreOperModelTypeId)
      and ([a].[USE_OPER_ONE] is null)
    ) [a] on [i].[ID]=[a].[ID]
  when not matched then
    insert ([ID]) values ([a].[ID]);
  return
end