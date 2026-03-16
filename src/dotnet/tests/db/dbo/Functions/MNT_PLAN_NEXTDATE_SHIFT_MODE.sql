-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-02-23
-- Description: Calculates or just returns [NEXTDATE_SHIFT_MODE] for specified maintenance plan.
-- =============================================
-- KB4452:2024-02-24: Initial update.
create function [dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE](@MntID int)
returns int as
begin
  declare @MntShiftFromLastDate     int = 0
  declare @MntShiftFromLastCmplDate int = 0
  declare @MntNDShiftMode           int = 0
  if @MntID is null return 0
  select
     @MntShiftFromLastDate=isnull([p].[SHIFTFROMLASTDATE],0)
    ,@MntShiftFromLastCmplDate=isnull([p].[SHIFTFROMLASTCMPLDATE],0)
    ,@MntNDShiftMode=[p].[NEXTDATE_SHIFT_MODE]
  from [dbo].[MNT_PLAN] [p] with(nolock)
  where [p].[ID]=@MntID
  if @MntNDShiftMode is not null
    if @MntNDShiftMode = 1 return 0
    else                   return @MntNDShiftMode
  if @MntShiftFromLastCmplDate = 1 return 2
  if @MntShiftFromLastDate     = 1 return 0
  return 0
end