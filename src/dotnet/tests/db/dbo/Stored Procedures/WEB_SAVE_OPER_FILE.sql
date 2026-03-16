CREATE procedure [dbo].[WEB_SAVE_OPER_FILE] @UserID int, @OperID int, @FileName nvarchar(255), @FileBlob image
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
  
insert into PR_OPERATION_FILES (GID,S_CR,S_CDT,OPERATIONID,FILENAME,FILESIZE,FILEDATE,FILEBLOB)
values (newid(),@UserID,getdate(),@OperID,@FileName,datalength(@FileBlob),getdate(),@FileBlob)

set nocount off