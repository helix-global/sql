CREATE FUNCTION [dbo].[WEB_FIND_DEVICEID_BY_OPERATION](@UserID int, @OperationId int)
RETURNS int
AS
BEGIN
  
  declare @res int
  
  select @res = A.DEVICEID
  from PR_OPERATION A with (nolock) 
  left join PR_DEVICE D with (nolock) on A.DEVICEID = D.ID
  where A.ID = @OperationId
    and A.S_S = 1000031 -- In progress
    and A.USERINPROGRESS = @UserID
    and D.MODELID in (select J.ID from dbo.PR_VIEWMODEL_TAB(@UserID,getdate()) J)
  
  if (@res is not null)
  begin
    return @res;  
  end
  
  select @res = A.DEVICEID
  from PR_OPERATION A with (nolock) 
  left join PR_DEVICE D with (nolock) on A.DEVICEID = D.ID
  where A.ID = @OperationId
    and A.S_S = 1000031 -- In progress
    and A.USERINPROGRESS = @UserID
    and D.MODELID in (select ID from dbo.PR_ACCESS_MODELS(@UserID,4,getdate()))
  
  return @res;

END