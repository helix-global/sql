CREATE FUNCTION [dbo].[SW_NEW_VER_HINT]
(
	@ToolID int
)
RETURNS nvarchar(100)
AS
BEGIN
  
  declare @latestVerSS int
  
  select top 1 @latestVerSS = A.S_S from SW_TOOL_VERSIONS A with (nolock) where A.TOOLID = @ToolID order by A.ID desc
  if @latestVerSS = 1
    return 'Unapproved new version'

  declare @LastLinkedVerID int
  select top 1 @latestVerSS = A.LINKVER from SW_TOOL_VERSIONS A with (nolock) where A.TOOLID = @ToolID and A.S_S = 1000061 order by A.ID desc  

  if @LastLinkedVerID is not null
  begin
    declare @toolL int
    select @toolL = A.TOOLID 
    from SW_TOOL_VERSIONS A with (nolock) 
    where A.ID = @LastLinkedVerID
    
    if exists (select B.ID 
                 from SW_TOOL_VERSIONS B with (nolock) 
                where B.TOOLID = @toolL 
                  and B.S_S = 1000061  
                  and B.ID > @LastLinkedVerID
                  )
       return 'New approved versions of the linked tool exists'                  
    
  end
  
  return null;

END