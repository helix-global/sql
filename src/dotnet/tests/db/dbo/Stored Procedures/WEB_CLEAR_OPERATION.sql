CREATE procedure [dbo].[WEB_CLEAR_OPERATION] @UserID int, @OperID int
as 

set nocount on

declare @ss int
declare @checkID int

select @ss = S_S 
      ,@checkID = ID
from PR_OPERATION 
where ID = @OperID

if @checkID is null
begin
  raiserror('Operation not found.',16,1)
  set nocount off
  return
end

if @ss <> 1000031 /*inprogress*/
begin
  raiserror('Operation cannot be changed out of the "In Progress" state.',16,1)
  set nocount off
  return
end

delete from PR_OPERATION_MU where OPERID = @OperID
delete from PR_OPERATION_UNINSTALL where OPERID = @OperID
delete from PR_OPERATION_INSTALL where OPERID = @OperID
delete from PR_OPERATION_PARAMS where OPERID = @OperID
delete from PR_OPERATION_FILES where OPERATIONID = @OperID
delete from PR_OPERATION_EXT_PARAMS where OPERID = @OperID

set nocount off