CREATE function [dbo].[PR_REPORT_USING2](@aReportID int,@aModelID int,@aRevID int)
returns int WITH SCHEMABINDING as 
begin
  if not exists (select A.ID from dbo.PR_REPORTS_T A with (nolock) where A.VNESHID = @aReportID)
    return 1
  if exists (select A.ID from dbo.PR_REPORTS_T A with (nolock) where A.VNESHID = @aReportID and A.REVID = @aRevID)  
    return 1
  
  if exists (select A.ID from dbo.PR_REPORTS_T A with (nolock) 
              where A.VNESHID = @aReportID 
                and A.MODELID = @aModelID
                and A.REVID is null                  
             )
           return 1                                  
  
  return 0
end