-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-02-23
-- Description: Calculates the amount of equipments.
-- =============================================
-- KB4452:2024-02-24: Initial update.
create function [dbo].[MNT_PLAN_EQ_COUNT] (@MntID int)
returns int as
begin
  declare @Count int = 0
  select top 1
    @Count=count(*)
  from [dbo].[MNT_PLAN] [p] with(nolock)
    inner join [dbo].[MNT_PLAN_EQ] [e] with(nolock) on [e].[VNESHID]=[p].[ID]
  where ([p].[ID]=@MntID)
  return @Count
end