create function [dbo].[PR_REPORT_USING](@aReportID int,@aRevID int)
returns int as 
begin
  if not exists (select A.ID from PR_REPORTS_T A with (nolock) where A.VNESHID = @aReportID)
    return 1
  if exists (select A.ID from PR_REPORTS_T A with (nolock) where A.VNESHID = @aReportID and A.REVID = @aRevID)  
    return 1
  
  if exists (select A.ID from PR_REPORTS_T A with (nolock) 
              where A.VNESHID = @aReportID 
                and A.MODELID = (select B.MODELID from PR_REVISION B with (nolock)
                                  where B.ID = @aRevID)  
                and A.REVID is null                  
             )
           return 1                                  
  
  return 0
end