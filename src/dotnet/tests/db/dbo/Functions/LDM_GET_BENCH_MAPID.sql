
CREATE FUNCTION [dbo].[LDM_GET_BENCH_MAPID] (@ModuleModelId int, @BenchModelId int)
RETURNS int
begin


   declare @res int
   declare @defaultMapID int
   
   select @defaultMapID = ID from PR_MAP with (nolock) where GID='C9A4266A-3033-423A-AD2C-824A9966D954'  /*Solder Bench Production*/
   
   if dbo.LDM_SETTING_INT('operation1_mapFromRev',null) = 1
   begin
   
		select @res = A.MAPID from PR_REVISION A with (nolock) where A.ID = dbo.LDM_GET_BENCH_REVISION(@ModuleModelId,@BenchModelId)
		return isnull(@res,@defaultMapID)
		
   end	
   
   return @defaultMapID

end