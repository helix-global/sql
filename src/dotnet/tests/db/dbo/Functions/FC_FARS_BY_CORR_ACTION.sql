CREATE function [dbo].[FC_FARS_BY_CORR_ACTION] (@aID int,@aMode int)
returns @res table (ID int)
as 
begin
/*выдает список ID FAR по одному Corrective Action*/


insert into @res (ID) 
  select distinct AA.ID
  from FC_CORRACTIONS A with (nolock)
  left join FC_REPORT_ANALYSIS_CODES B with (nolock) on B.ANALYSISCODEID = A.ANALYSISCODEID
  left join FC_REPORT_CODES C with (nolock) on C.ID = B.FCODE
  left join FC_REPORT AA with (nolock) on AA.ID = B.VNESHID
  where A.ID = @aID
    and ( A.FAILURE_CODE is null or C.REPCODEID = A.FAILURE_CODE)
    and ( AA.MODELID in (select GG.MODELID from FC_CORRACTIONS_MODELS GG with (nolock) where GG.VNESHID = A.ID)
          or not exists  (select GG.MODELID from FC_CORRACTIONS_MODELS GG  with (nolock) where GG.VNESHID = A.ID)
         )  

return

end