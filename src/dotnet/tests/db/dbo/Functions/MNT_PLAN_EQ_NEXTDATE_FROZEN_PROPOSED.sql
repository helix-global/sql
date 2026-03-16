-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-07-23
-- Description: Proposes value for field [NEXTDATE_FROZEN].
-- =============================================
-- KB4880:2024-07-23: Initial update.
create function [dbo].[MNT_PLAN_EQ_NEXTDATE_FROZEN_PROPOSED](@MntEqID int,@MntEqNextDate datetime,@MntEqNextDateFrozen int)
returns int
as
begin
  if @MntEqID < 0
  begin
    if @MntEqNextDate is not null
      return 1
    else
      return 0
  end

  declare @MntEqNextDateOLD datetime = null
  select
    @MntEqNextDateOLD=[a].[NEXTDATE]
  from [dbo].[MNT_PLAN_EQ] [a] with(nolock)
  where [a].[ID]=@MntEqID

  if @MntEqNextDate is not null and @MntEqNextDateOLD<>@MntEqNextDate
  begin
    return 1
  end

  return @MntEqNextDateFrozen
end