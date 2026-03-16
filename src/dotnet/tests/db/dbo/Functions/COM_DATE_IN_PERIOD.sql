

-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-01-28
-- Description: Verifying that the specified "datetime" is in the period.
-- =============================================
-- KB4914:2025-01-28: Initial update.
CREATE function [dbo].[COM_DATE_IN_PERIOD](@PeriodBeg datetime,@PeriodEnd datetime,@MeasurementDate datetime)
returns int
as
begin
  return case when [dbo].[COM_DATE_PERIOD_IS_OVERLAPED](@PeriodBeg,@PeriodEnd,@MeasurementDate,@MeasurementDate) > 0
    then 1 else 0 end
end