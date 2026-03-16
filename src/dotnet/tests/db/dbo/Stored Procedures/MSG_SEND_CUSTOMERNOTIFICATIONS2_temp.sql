CREATE PROCEDURE [dbo].[MSG_SEND_CUSTOMERNOTIFICATIONS2_temp] @aUserID int
AS
BEGIN
/*
   версия 2 посылает несколько строк по одной подписке из MSG_FILENOTIFICATIONS_OUT одним письмом
*/
    set nocount on

    declare @now datetime
    set @now = getdate()
    
    if not exists (select ID from MSG_FILENOTIFICATIONS_OUT where S_S = 1000183/*ready to sent*/  )
    begin
      set nocount off
      return
    end
    
    declare @messID int
    declare @lines table(ID int not null)
    declare @subscrID int
    declare @i int = 0
    
    
    while (@i < 12)
    begin
      set @i = @i + 1
    
      delete from @lines
      set @subscrID = null
       
      select top 1 @subscrID = A.SBSCID
	  from MSG_FILENOTIFICATIONS_OUT A with (nolock) 
	  left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
	 where A.S_S = 1000183/*ready to sent*/ 
	   and dateadd(hour,B.SENDDELAY,A.READYDT) <= @now /*вышло время задержки*/ 
	   and B.S_S = 1000176 /*approved*/
      
      if @subscrID is null break;
       
      insert into @lines (ID)
      select A.ID
      from MSG_FILENOTIFICATIONS_OUT A with (nolock) 
	  left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
	 where A.S_S = 1000183/*ready to sent*/ 
	   and A.SBSCID = @subscrID
	   and dateadd(hour,B.SENDDELAY,A.READYDT) <= @now /*вышло время задержки*/ 
	   and B.S_S = 1000176 /*approved*/

      if exists (select * from @lines)
      begin
         
        set @messID = null 
		
		INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR, CUSTOMERSUBSCRID ,MSGBCC) 
		select 0,newid(),B.ADR,B.CC,B.SUBJ,B.MSG,getdate(),@aUserID, B.ID, B.BCC
		from MSG_FILENOTIFICATIONS B with (nolock) 
		where B.ID = @subscrID
	      
		set @messID = @@identity

		insert into MSG_OUT_ATTACHEMENTS (GID,VNESHID,FILENAME,FILEDATE,FILESIZE,FILEBLOB)
		select newid(),@messID,A.FILENAME,A.FILEDATE,A.FILESIZE,A.FILEBLOB
		from MSG_FILENOTIFICATIONS_OUT_FILES A with (nolock)
		where A.VNESHID in (select ID from @lines)

		update MSG_OUTGOING set S_S = 1 where MSG_OUTGOING.ID = @messID
		
		update MSG_FILENOTIFICATIONS_OUT set S_S = 1000180 /*sent*/, SENTDATE = getdate(), MSGID = @messID  where MSG_FILENOTIFICATIONS_OUT.ID in (select ID from @lines)
       
      end
    
    end
	
	set nocount off	
END