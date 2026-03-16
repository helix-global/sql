create function [dbo].[LDM_SETTING_OPERATIONID](@aSettingLabel nvarchar(50), @aOperationGID uniqueidentifier)
returns int as 
begin
  
  declare @res int
  
  select top 1 @res = A.VALUEINT from LDM_SETTINGS A with (nolock) where A.LABEL = @aSettingLabel and A.TYPE = 2 /*operation form*/
  
  if @res is null
     select @res = A.ID from PR_OPERATIONS A with (nolock) where A.GID = @aOperationGID
     
  return @res   

end