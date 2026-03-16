CREATE function [dbo].[PR_GET_PARAM_ID](@gid uniqueidentifier)
returns int as 
begin
  return (select ID from PR_MODELTYPE_PARAMS with (nolock) where GID=@gid) 
end