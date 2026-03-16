-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-06-03
-- Description: Updates [NEXTDATE] field for equipment with proposed value if it not frozen.
-- =============================================
-- KB4880:2024-07-23: Fixed condition error.
-- KB4818:2024-06-03: Initial update.
CREATE procedure [dbo].[MNT_PLAN_EQ_RECALCULATE_NEXT_DATE] @MntPlanID int
as
begin
  set nocount on;
  declare @UpdatedRecordsT table([MNT_PLAN_EQ_ID] int)
  update [e]
    set [e].[NEXTDATE] = [dbo].[MNT_NEXT_SNOOZE4](null,[e].[ID],null)
  output
    INSERTED.ID
    into @UpdatedRecordsT
  from [dbo].[MNT_PLAN_EQ] [e]
    inner join [dbo].[MNT_PLAN] [p] with(nolock) on [p].[ID]=[e].[VNESHID]
  where (([p].[ID] = @MntPlanID) or (@MntPlanID is null))
    and [p].[S_S] = 1
    and [e].[NEXTDATE_FROZEN]<>1

  select *
  from @UpdatedRecordsT [a]
    inner join [dbo].[MNT_PLAN_EQ] [b] with(nolock) on [b].[ID]=[a].[MNT_PLAN_EQ_ID]
end