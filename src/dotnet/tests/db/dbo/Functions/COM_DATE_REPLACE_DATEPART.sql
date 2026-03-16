
-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-01-28
-- Description: The function replace datepart of input "datetime" with specified value.
-- =============================================
CREATE function [dbo].[COM_DATE_REPLACE_DATEPART](@SourceDateTime datetime,@DateReplacement date)
returns datetime
as
begin
  if @SourceDateTime is not null
  begin
    if @DateReplacement is not null
    begin
      set @SourceDateTime = datetimefromparts(
        year(@DateReplacement),month(@DateReplacement),day(@DateReplacement),
          datepart(hh,@SourceDateTime),
          datepart(mi,@SourceDateTime),
          datepart(ss,@SourceDateTime),
          datepart(ms,@SourceDateTime))
    end
  end
  return @SourceDateTime
end