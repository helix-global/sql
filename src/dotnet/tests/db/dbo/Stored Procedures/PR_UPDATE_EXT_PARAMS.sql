create procedure [dbo].[PR_UPDATE_EXT_PARAMS] @OperID int, @CloseWithErr int, @UserID int
as 
set nocount on

if not exists (select A.ID from PR_OPERATION_EXT_PARAMS A where A.OPERID = @OperID)
begin
   set nocount off
   return
end

update PR_OPERATION_EXT_PARAMS set DEVICEID = dbo.PR_FIND_EXT_DEVICEID(@OperID,BOMID,BOMID2,BOMID3)
where PR_OPERATION_EXT_PARAMS.OPERID = @OperID

set nocount off