
CREATE FUNCTION [dbo].[SW_TOOL_LATEST_VER](	@ToolID int, @aMode int)
RETURNS int
AS
BEGIN
  
  declare @latestVerID int
  
  select top 1 @latestVerID = A.ID
  from SW_TOOL_VERSIONS A with (nolock) 
  where A.TOOLID = @ToolID 
  and A.S_S = 1000061/*approved*/ 
  order by A.ID desc
  
  return @latestVerID;

END