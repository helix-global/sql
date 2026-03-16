-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-02-23
-- Description: Calculates [LASTDATE] for specified equipment.
-- =============================================
-- KB4452:2024-02-24: Initial update.
CREATE function [dbo].[MNT_PLAN_EQ_LASTDATE] (@MntEqID int)
returns datetime as
begin
  declare @D datetime = null
  select top 1
    @D=[o].[COMPLETED_DT]
  from [dbo].[MNT_PLAN_EQ] [e] with(nolock)
    inner join [dbo].[MNT_PLAN]     [p] with(nolock) on [p].[ID]=[e].[VNESHID]
    inner join [dbo].[PR_OPERATION] [o] with(nolock) on [o].[MNT_PLANID]=[p].[ID] and [o].[EQID]=[e].[EQID]
  where ([o].[S_S] in (1000013,1000019))
    and ([o].[COMPLETED_DT] is not null)
    and ([e].[ID]=@MntEqID)
  order by [o].[COMPLETED_DT] desc
  if @D is null
  begin
    select
      @D=[e].[S_CDT]
    from [dbo].[MNT_PLAN_EQ] [e] with(nolock)
    where ([e].[ID]=@MntEqID)
  end
  return @D
end