CREATE FUNCTION [dbo].[LDM_GET_BENCH_REVISION2] (@ModuleModelId int, @BenchModelId int, @BenchBomId int)
RETURNS int
begin

declare @result int 

select top 1 @result = VALUEINT2 from LDM_SETTINGS with(nolock) where LABEL like 'moduleBenchBomMap%' and PRM=@BenchBomId and VALUEINT=@ModuleModelId

if @result is null
begin
  set @result = dbo.LDM_GET_BENCH_REVISION(@ModuleModelId, @BenchModelId)
end

return @result

end