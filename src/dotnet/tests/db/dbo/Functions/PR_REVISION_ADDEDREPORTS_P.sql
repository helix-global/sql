-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-11-21
-- Description: Returns identifiers of [PR_REPORT] instances associated with specified revision data.
-- =============================================
-- KB5053:2024-11-21: Initial update.
create function [dbo].[PR_REVISION_ADDEDREPORTS_P](@UserID int,@RevID int,@Options nvarchar(max))
returns nvarchar(max)
as
begin
  declare @Output nvarchar(max)
  select
     @Output=[dbo].[GROUP_CONCAT_D](cast([a].[ID] as nvarchar(max)),';')
  from [dbo].[PR_REVISION_ADDEDREPORTS_T](@UserID,@RevID,@Options) [a]
  return @Output
end