
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-03-04
-- Description: Calculates equipment work cycles affected due maintenance plan.
-- =============================================
-- KB4645:2024-03-04: Initial update.
-- KB4680:2024-03-27: Fixed to use 'datetime' type.
CREATE function [dbo].[MNT_PLAN_EQ_WORKCYCLES] (@MntEqID int)
returns int as
begin
  if @MntEqID is null return 0
  declare @PeriodBeg datetime = null
  declare @EqId int = 0
  select
     @EqId = [a].[EQID]
    ,@PeriodBeg = isnull([dbo].[MNT_PLAN_EQ_LASTDATE]([a].[ID]),[b].[DBEG])
  from [dbo].[MNT_PLAN_EQ] [a] with(nolock)
    inner join [dbo].[MNT_PLAN] [b] with(nolock) on [b].[ID]=[a].[VNESHID]
  where [a].[ID]=@MntEqID
  return [dbo].[EQ_WORKCYCLES](@EqId,@PeriodBeg,getdate(),0)
end