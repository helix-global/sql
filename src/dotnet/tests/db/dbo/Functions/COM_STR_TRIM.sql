-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-08-13
-- Description: Removes all the leading and trailing occurrences of a set of characters specified in an array from the current string.
-- =============================================
-- KB4717:2024-08-13: Initial update.
create function [dbo].[COM_STR_TRIM](@Value nvarchar(max),@TrimCharacters nvarchar(max))
returns nvarchar(max)-- with schemabinding
as
begin
  if @Value is null return null
  return [dbo].[COM_STR_RTRIM]([dbo].[COM_STR_LTRIM](@Value,@TrimCharacters),@TrimCharacters)
end