CREATE procedure [dbo].[WEB_SAVE_OPER_MATERIAL] @UserID int, @OperID int, @PN nvarchar(300), @BatchN nvarchar(100), @Qty decimal(20,10)
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
  
insert into PR_OPERATION_MU (GID,S_CR,S_CDT,OPERID,CODE,QUANTITY,BATCHN)
values (newid(),@UserID,getdate(),@OperID,@PN,@Qty,@BatchN)

set nocount off