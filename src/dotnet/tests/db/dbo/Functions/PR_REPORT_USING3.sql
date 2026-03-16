create function [dbo].[PR_REPORT_USING3](@aReportID int,@aDeviceID int)
returns int as 
begin
  
  declare @ModelID int
  declare @RevID int
  
  select @RevID = A.REVID
        ,@ModelID = A.MODELID 
  from PR_DEVICE A with (nolock) 
  where A.ID = @aDeviceID

  if not exists (select A.ID from PR_REPORTS_T A with (nolock) where A.VNESHID = @aReportID)
    return 1
    
  if exists (select A.ID from PR_REPORTS_T A with (nolock) where A.VNESHID = @aReportID and A.REVID = @RevID)  
    return 1
  
  if exists (select A.ID from PR_REPORTS_T A with (nolock) 
              where A.VNESHID = @aReportID 
                and A.MODELID = @ModelID
                and A.REVID is null                  
             )
           return 1                                  
  
  return 0
end