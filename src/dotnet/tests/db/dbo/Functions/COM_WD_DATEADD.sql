-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-05-23
-- Description: This function adds a number (a signed integer) of working days to an input date, and returns a modified date value.
-- =============================================
create function [dbo].[COM_WD_DATEADD](@Date date, @Days int, @CalendarID int, @Mode int)
returns date
as
begin
  if @Date is not null
  begin
    while @Days > 0
    begin
      set @Days = @Days - 1
      set @Date = dateadd(dd,1,@Date)
      while [dbo].[COM_IS_WORKDAY](@Date,@CalendarID) <> 1
      begin
        set @Date = dateadd(dd,1,@Date)
      end
    end
  end
  return @Date
end