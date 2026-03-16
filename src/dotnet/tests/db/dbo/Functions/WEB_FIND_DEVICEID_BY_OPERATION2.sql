CREATE FUNCTION [dbo].[WEB_FIND_DEVICEID_BY_OPERATION2](@UserID int, @OperationId int)
RETURNS int
AS
BEGIN
  
  declare @res int
  declare @modelid int
  
  select @res = A.DEVICEID
         ,@modelid = D.MODELID
  from PR_OPERATION A with (nolock) 
  left join PR_DEVICE D with (nolock) on A.DEVICEID = D.ID
  where A.ID = @OperationId
    and A.S_S = 1000031 -- In progress
    and A.USERINPROGRESS = @UserID
  
  if (@res is not null)
  begin
    if @modelid in (select J.ID from dbo.PR_VIEWMODEL_TAB(@UserID,getdate()) J)
    begin
		return @res
	end
    if @modelid in (select ID from dbo.PR_ACCESS_MODELS(@UserID,4,getdate()))
    begin
        return @res
    end		
  end
  
  return null
  
END