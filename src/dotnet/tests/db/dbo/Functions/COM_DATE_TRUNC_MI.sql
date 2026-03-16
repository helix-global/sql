
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-01-28
-- Description: The function returns an input date truncated to a "minute" datepart.
-- =============================================
create function [dbo].[COM_DATE_TRUNC_MI](@Value datetime)
returns datetime
as
begin
  if @Value is not null
  begin
    set @Value = datetimefromparts(
      year(@Value),month(@Value),day(@Value),
      datepart(hh,@Value),datepart(mi,@Value),0,0)
  end
  return @Value
end