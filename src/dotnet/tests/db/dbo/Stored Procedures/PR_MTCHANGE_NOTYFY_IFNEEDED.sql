CREATE PROCEDURE [dbo].PR_MTCHANGE_NOTYFY_IFNEEDED @mtid int, @ntype int, @UserID int, @changes nvarchar(max)
AS
BEGIN
  set nocount on

  declare @to nvarchar(1024)
  declare @toCC nvarchar(1024)
  declare @mtname nvarchar(max)
  
  select @mtname = A.NAME from PR_MODELTYPE A with(nolock) where A.ID = @mtid

  declare @oneMessage nvarchar(max)
  set @oneMessage = 'Dear All,<br><br>Element in model type "'+@mtname+'" was changed.<br><br>'+
  @changes+'<br><br>Please do not reply,<br>PDB'

  declare nxx cursor local read_only for 
  select MSGTO,MSGCC 
  from PR_MT_CHANGE_NOTIFY A with(nolock) 
  where A.MTID = @mtid
    and A.CHTYPE = @ntype
 
  open nxx 
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM nxx INTO @to, @toCC
    IF @@FETCH_STATUS<>0 BREAK;
    
    if @to is not null
    begin
    
		exec MSG_SEND2 @UserID, @to, @toCC, 'Model Type Changes Notification', @oneMessage
		
	end	
    
  END
  close nxx;
  deallocate nxx;   

  set nocount off
END