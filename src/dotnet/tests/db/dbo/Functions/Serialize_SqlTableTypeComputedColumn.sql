

-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2025-03-18
-- Description: Serialize [SqlTableTypeComputedColumn] into xml.
-- =============================================
-- KB5302:2025-03-18: Initial Update.
create function [dbo].[Serialize_SqlTableTypeComputedColumn](@ObjectID int,@ColumnID int)
returns xml
as
begin
  declare @Out xml
  return @Out
end