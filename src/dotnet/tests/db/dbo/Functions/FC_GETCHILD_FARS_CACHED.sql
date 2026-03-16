-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-06-25
-- Description: Returns child FARs for specified ID. Similar to [dbo].[FC_GETCHILD_FARS] but used cached data from [OLAP_JOB_RESULT_FC_GETCHILD_FARS].
-- =============================================
-- KB4660:2024-06-26: Initial update.
create function [dbo].[FC_GETCHILD_FARS_CACHED] (@ParentID int)
returns table
as
return
  (
  select
    [a].[FC_REPORT_CHILDID] [ID]
  from [dbo].[OLAP_JOB_RESULT_FC_GETCHILD_FARS] [a] with(nolock)
  where [a].[FC_REPORT_PARENTID]=@ParentID
  )