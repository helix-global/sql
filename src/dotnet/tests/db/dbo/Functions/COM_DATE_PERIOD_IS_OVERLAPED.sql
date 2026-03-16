
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-01-28
-- Description: Checking date periods for overlapping.
-- =============================================
-- KB4914:2025-01-28: Initial update.
CREATE function [dbo].[COM_DATE_PERIOD_IS_OVERLAPED](@PeriodBegA datetime,@PeriodEndA datetime,@PeriodBegB datetime,@PeriodEndB datetime)
returns int
as
begin
  ------------------------|-------B-------|-----------------------------------------------
  --    |----A01---|                                             After                 :-1
  --           |----A02---|                                      StartTouching         :01
  --               |----A03---|                                  StartInside           :02
  --               |----------A04---------|                      InsideEndTouching     :03
  --               |----------------A05---------------|          Inside                :04
  --                      |----A06---|                           EnclosingStartTouching:05
  ------------------------|-------B-------|-----------------------------------------------
  --                      |------A07------|                      ExactMatch            :06
  --                      |----------A08----------|              InsideStartTouching   :07
  --                         |----A09---|                        Enclosing             :08
  --                         |----A10-----|                      EnclosingEndTouching  :09
  --                         |--------A11--------|               EndInside             :10
  --                                      |----A12----|          EndTouching           :11
  --                                         |----A13----|       Before                :-2
  ------------------------|-------B-------|-----------------------------------------------

  if (@PeriodBegA is null or @PeriodEndA is null or @PeriodBegB is null or @PeriodEndB is null)
  begin
    return 0
  end
  if @PeriodBegA < @PeriodBegB
  begin
    /*A01*/ if @PeriodEndA < @PeriodBegB return -1
    /*A02*/ if @PeriodEndA = @PeriodBegB return  1
    /*A03*/ if @PeriodEndA > @PeriodBegB and @PeriodEndA < @PeriodEndB return 2
    /*A04*/ if @PeriodEndA > @PeriodBegB and @PeriodEndA = @PeriodEndB return 3
    /*A05*/ if @PeriodEndA > @PeriodBegB and @PeriodEndA > @PeriodEndB return 4
  end else
  if @PeriodBegA = @PeriodBegB
  begin
    /*A06*/ if @PeriodEndA < @PeriodEndB return 5
    /*A07*/ if @PeriodEndA = @PeriodEndB return 6
    /*A08*/ if @PeriodEndA > @PeriodEndB return 7
  end else
  if @PeriodBegA > @PeriodBegB
  begin
    /*A12*/ if @PeriodBegA = @PeriodEndB return 11
    /*A13*/ if @PeriodBegA > @PeriodEndB return -2
    /*A09*/ if @PeriodEndA < @PeriodEndB return  8
    /*A10*/ if @PeriodEndA = @PeriodEndB return  9
    /*A11*/ if @PeriodEndA > @PeriodEndB return 10
  end
  return 0
end