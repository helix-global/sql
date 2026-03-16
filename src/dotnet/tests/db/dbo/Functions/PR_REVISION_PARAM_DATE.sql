-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-03-01
-- Description: Fetch specified revision parameter as "date".
-- =============================================
-- KB4638:2024-03-01: Initial update.
create function [dbo].[PR_REVISION_PARAM_DATE](@RevisionID int, @ParamID int)
returns datetime as
begin
  return cast([dbo].[COM_CONVERT_TO_DT](
    [dbo].[PR_REVISION_PARAM](
      @RevisionID,
      @ParamID)) as date)
end