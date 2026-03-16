create function [dbo].[FC_FAR_ISLINKEDTOCODES](@aFarID int, @aFailureCodeID int,@aAnalysisCodeID int)
returns int as 
begin

  if @aFailureCodeID is not null
  begin
     if exists (select A.ID 
                  from FC_REPORT_ANALYSIS_CODES_T A with (nolock) 
                  left join FC_REPORT_ANALYSIS_CODES B with (nolock) on B.ID = A.VNESHID
                  left join FC_REPORT_CODES C with (nolock) on C.ID = B.FCODE 
                 where A.REPORTID = @aFarID
                   and C.REPCODEID = @aFailureCodeID
                   )
          return 1         
  end
  
  if @aAnalysisCodeID is not null
  begin
     if exists (select A.ID 
                  from FC_REPORT_ANALYSIS_CODES_T A with (nolock) 
                  left join FC_REPORT_ANALYSIS_CODES B with (nolock) on B.ID = A.VNESHID
                 where A.REPORTID = @aFarID
                   and B.ANALYSISCODEID = @aAnalysisCodeID
                   )
          return 1         
  end
    
  return 0;
end