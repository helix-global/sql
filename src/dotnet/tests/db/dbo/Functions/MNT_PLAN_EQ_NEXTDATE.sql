-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-02-23
-- Description: Calculates proposed value for [NEXTDATE]
-- =============================================
-- KB4452:2024-02-23: Initial update.
create function [dbo].[MNT_PLAN_EQ_NEXTDATE] (@MntEqID int)
returns datetime as
begin
  declare @D datetime = null
  select top 1
    @D=[e].[NEXTDATE]
  from [dbo].[MNT_PLAN_EQ] [e] with(nolock)
  where ([e].[ID]=@MntEqID)
  return isnull([dbo].[MNT_NEXT_SNOOZE4](null,@MntEqID,null),@D)
end