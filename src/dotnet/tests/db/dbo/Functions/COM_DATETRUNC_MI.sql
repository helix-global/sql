-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-04-19
-- Description: The function returns an input date truncated to a "minute" datepart.
-- =============================================
-- @Obsolete
CREATE function [dbo].[COM_DATETRUNC_MI](@Value datetime)
returns datetime
as
begin
  return [dbo].[COM_DATE_TRUNC_MI](@Value)
end