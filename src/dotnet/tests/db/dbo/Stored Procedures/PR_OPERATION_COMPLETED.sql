-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-03-27
-- Description: "Operation completed" event handler
-- =============================================
create procedure [dbo].[PR_OPERATION_COMPLETED]
  @OperID int,
  @UserID int
as
begin
  set nocount on

  declare @MntPlanEQRowID int = null
  select
    @MntPlanEQRowID=[a].[MNT_PLAN_EQROW_ID]
  from [dbo].[PR_OPERATION] [a] with(nolock)
  where [a].[ID]=@OperID

  if @MntPlanEQRowID is not null
  begin
    update [dbo].[MNT_PLAN_EQ] set
      [NEXTDATE_FROZEN]=0
    where [ID]=@MntPlanEQRowID
  end
end