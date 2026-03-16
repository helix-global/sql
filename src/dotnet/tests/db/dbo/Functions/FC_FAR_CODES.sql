CREATE function [dbo].[FC_FAR_CODES] (@aFarID int)
returns table 
as 
return   
select A.REPCODEID , A.DISCOVERED, B.ANALYSISCODEID, B.INITI, B.OPTS
from FC_REPORT_CODES A
left join FC_REPORT_ANALYSIS_CODES B on B.FCODE = A.ID and B.VNESHID = A.VNESHID
where A.VNESHID = @aFarID
union all
select null, null, A.ANALYSISCODEID, A.INITI, A.OPTS
from FC_REPORT_ANALYSIS_CODES A 
where A.VNESHID = @aFarID
  and A.FCODE is null