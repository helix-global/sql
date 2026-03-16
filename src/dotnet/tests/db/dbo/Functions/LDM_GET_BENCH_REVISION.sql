CREATE FUNCTION [dbo].[LDM_GET_BENCH_REVISION] (@ModuleModelId int, @BenchModelId int)
RETURNS int
begin

declare @BenchBomId int
select @BenchBomId=B.BOMID
from PR_REVISION R
left join PR_REV_BOM2 B with (nolock) on B.REVID = R.ID
where B.PARTMODELID=@BenchModelId

return
  isnull(
     (select top(1) VALUEINT2 from LDM_SETTINGS with(nolock) where LABEL like 'moduleBenchBomMap%' and PRM=@BenchBomId and VALUEINT=@ModuleModelId)
    ,(select top(1) R.ID from PR_REVISION R with(nolock) where R.MODELID=@BenchModelId and R.S_S=1000017 /*Approved*/ order by R.NAME desc)
  )

end