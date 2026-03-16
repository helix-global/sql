create function [dbo].[PR_UNINSTALL_ID](@aInstallID int)
returns int
as
begin

  declare @unID int
  
  select top 1 @unID = A.ID
  from  PR_OPERATION_UNINSTALL A with (nolock) 
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where A.INSTALLROWID = @aInstallID
    and B.S_S IN (1000013, 1000019)
  
  return @unID

end;