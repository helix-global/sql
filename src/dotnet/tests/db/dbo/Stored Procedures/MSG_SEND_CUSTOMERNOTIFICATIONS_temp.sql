CREATE PROCEDURE [dbo].[MSG_SEND_CUSTOMERNOTIFICATIONS_temp]
AS
BEGIN

    set nocount on
    
    if not exists (select ID from MSG_FILENOTIFICATIONS_OUT where S_S = 1000183/*ready to sent*/)
    begin
      set nocount off
      return
    end
    
    declare @now datetime
    set @now = getdate()
    
	declare @id int
	declare nxx cursor local read_only for 
	select A.ID 
	  from MSG_FILENOTIFICATIONS_OUT A with (nolock) 
	  left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
	 where A.S_S = 1000183/*ready to sent*/ 
	   and dateadd(hour,B.SENDDELAY,A.READYDT) <= @now /*вышло время задержки*/ 
	   and B.S_S = 1000176 /*approved*/
	open nxx 
	WHILE 1=1
	BEGIN
	FETCH NEXT FROM nxx INTO @id;
	IF @@FETCH_STATUS<>0 BREAK;

		exec MSG_SEND_CUSTOMERNOTIFICATION @id

	END
	close nxx;
	deallocate nxx;    
	
	
	set nocount off	
END