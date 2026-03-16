CREATE procedure [dbo].[WEB_SAVE_OPER_FILE2] @UserID int, @OperID int, @FileName nvarchar(255), @FileBlob image, @FilePreview image
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

declare @paramID int = null

select top 1 @paramID = A.PARAMID
from PR_OPERATION_PARAMS A with (nolock)
left join PR_MODELTYPE_PARAMS B with (nolock) on B.ID = A.PARAMID
where A.OPERID = @OperID
  and B.DATATYPE in (7,8) 
  and A.PVALUE = @FileName
  
insert into PR_OPERATION_FILES (GID,S_CR,S_CDT,OPERATIONID,FILENAME,FILESIZE,FILEDATE,FILEBLOB,FILEPREVIEW,PARAMID)
values (newid(),@UserID,getdate(),@OperID,@FileName,datalength(@FileBlob),getdate(),@FileBlob,@FilePreview,@paramID)

set nocount off