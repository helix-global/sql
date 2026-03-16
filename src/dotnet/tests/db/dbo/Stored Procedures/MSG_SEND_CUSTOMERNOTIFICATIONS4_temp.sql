CREATE PROCEDURE [dbo].[MSG_SEND_CUSTOMERNOTIFICATIONS4_temp] @aUserID int
AS
BEGIN
/*
   версия 2 посылает несколько строк по одной подписке из MSG_FILENOTIFICATIONS_OUT одним письмом
   
   версия 3 обрабатывает вставки: 
   <SNs> 
   <ModelName,SN,SO table> 
   <ModelName,SN table>
   
   версия 4 разбивает по письмам или с одной строкой или не больше 7MB файлов в одном 
   
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
    declare @lines table(ROWID int not null identity,ID int not null,FILESIZE_KB decimal(20,2))
    declare @subscrID int
    declare @i int = 0
    declare @sns nvarchar(max) 
    declare @table1 nvarchar(max) 
    declare @table2 nvarchar(max) 
    
    declare @ticketlines table(ID int not null,TICKETID int,NEWEXPIRED datetime)
    
    /* 1 выкладка тикетов (здесь записываются файлы и меняется состояние тикета, затем служба выложит это на WEB Server) */
    insert into @ticketlines (ID, TICKETID, NEWEXPIRED)
    select A.ID 
          ,(select top 1 B.ID from CP_TICKETS B with (nolock) where B.DEVICEID = A.DEVICEID and B.AUTOCREATED = 1 and B.S_S = 2000005/*reserved*/) as TICKETID
          ,dateadd(day,B.TICKETEXP,getdate()) as EXPIRED
    from MSG_FILENOTIFICATIONS_OUT A with (nolock)
    left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
    where A.S_S = 1000183 /*ready to sent*/ 
      and B.S_S = 1000176 /*approved*/
	  and B.STYPE in (2,3) /*with tickets*/

    update MSG_FILENOTIFICATIONS_OUT set TICKETID = (select B.TICKETID from @ticketlines B where B.ID = MSG_FILENOTIFICATIONS_OUT.ID)
    where MSG_FILENOTIFICATIONS_OUT.ID in (select ID from @ticketlines)
    
    delete from CP_TICKET_ATTACHEMENTS where VNESHID in (select C.TICKETID from @ticketlines C where C.TICKETID is not null)
    
    insert into CP_TICKET_ATTACHEMENTS (GID,S_CR,S_CDT,VNESHID,FILENAME,FILEDATE,FILESIZE,FILEBLOB,FILEDESC)
    select newid(),@aUserID,getdate(),A.TICKETID,B.FILENAME,B.FILEDATE,B.FILESIZE,B.FILEBLOB,null /*TODO что в описание записать*/
    from @ticketlines A
    left join MSG_FILENOTIFICATIONS_OUT_FILES B with (nolock) on B.VNESHID = A.ID
    where A.TICKETID is not null
    
    update CP_TICKETS set S_S = 1
          ,EXPIRED = (select B.NEWEXPIRED from @ticketlines B where B.TICKETID = CP_TICKETS.ID)
    where CP_TICKETS.ID in (select C.TICKETID from @ticketlines C where C.TICKETID is not null)
    
    /* 2 оправка писем */
    
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
	   and B.STYPE in (1,3) /*with email*/
      
      if @subscrID is null break;
       
      insert into @lines (ID,FILESIZE_KB)
      select A.ID
           , (select sum(D.FILESIZE/1024) from MSG_FILENOTIFICATIONS_OUT_FILES D with (nolock) where D.VNESHID = A.ID) as KB
      from MSG_FILENOTIFICATIONS_OUT A with (nolock) 
	  left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
	 where A.S_S = 1000183/*ready to sent*/ 
	   and A.SBSCID = @subscrID
	   and dateadd(hour,B.SENDDELAY,A.READYDT) <= @now /*вышло время задержки*/ 
	   and B.S_S = 1000176 /*approved*/
	   and B.STYPE in (1,3) /*with email*/

      if exists (select * from @lines)
      begin

       /* убираются строки при превышении 7 MB - они обработаются в следующий заход */ 
	   delete from @lines 
	   where (select sum(isnull(B.FILESIZE_KB,0)) from @lines B where B.ROWID <= "@lines".ROWID) > 7*1024
	     and ROWID > (select min(L.ROWID) from @lines L) /*первая строка должна остаться*/
        
        set @sns = null
        set @table1 = null
        set @table2 = null
        
        select @sns = isnull(@sns,'') + isnull(C.SN,'NA')+','
              ,@table1 = isnull(@table1,'') + '<tr><td>'+isnull(D.NAME,'NA')+'</td><td>'+isnull(C.SN,'NA')+'</td><td>'+isnull(dbo.COM_EXTR_WORD(B.READYNAVMSG,5,';'),'NA')+'</td></tr>'
              ,@table2 = isnull(@table2,'') + '<tr><td>'+isnull(D.NAME,'NA')+'</td><td>'+isnull(C.SN,'NA')+'</td></tr>'
        from @lines A
        left join MSG_FILENOTIFICATIONS_OUT B with (nolock) on B.ID = A.ID
        left join PR_DEVICE C with (nolock) on C.ID = B.DEVICEID
        left join PR_MODELS D with (nolock) on D.ID = C.MODELID
        
        set @sns = isnull(@sns,'NA')
        if @sns like '%,'
          set @sns = substring(@sns,0,len(@sns))
         
        set @table1 = '<tr><th>Model</th><th>Serial Number</th><th>Order Reference</th></tr>'+isnull(@table1,'') 
        set @table2 = '<tr><th>Model</th><th>Serial Number</th></tr>'+isnull(@table2,'') 
         
        declare @msSubj nvarchar(1024)
        declare @msBody nvarchar(max)
        select @msSubj = B.SUBJ
              ,@msBody = B.MSG
        from MSG_FILENOTIFICATIONS B with (nolock) 
        where B.ID = @subscrID
         
        set @msSubj = replace(@msSubj,'<SNs>',@sns) 

        set @msBody = replace(@msBody,'<SNs>',@sns) 
        set @msBody = replace(@msBody,'<ModelName,SN,SO table>',@table1) 
        set @msBody = replace(@msBody,'<ModelName,SN table>',@table2) 
         
        set @messID = null 
		
		INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR, CUSTOMERSUBSCRID ,MSGBCC) 
		select 0,newid(),B.ADR,B.CC,@msSubj,@msBody,getdate(),@aUserID, B.ID, B.BCC
		from MSG_FILENOTIFICATIONS B with (nolock) 
		where B.ID = @subscrID
	      
		set @messID = @@identity

		insert into MSG_OUT_ATTACHEMENTS (GID,VNESHID,FILENAME,FILEDATE,FILESIZE,FILEBLOB)
		select newid(),@messID,A.FILENAME,A.FILEDATE,A.FILESIZE,A.FILEBLOB
		from MSG_FILENOTIFICATIONS_OUT_FILES A with (nolock)
		left join MSG_FILENOTIFICATIONS_OUT B with (nolock) on B.ID = A.VNESHID
		left join MSG_FILENOTIFICATIONS C with (nolock) on C.ID = B.SBSCID
		where A.VNESHID in (select ID from @lines)
	  	  and C.STYPE = 1 /* файлы в письмо только с типом email, в остальных выкладываются на портал */

		update MSG_OUTGOING set S_S = 1 /*1000205*/ /* 1 !!! */ where MSG_OUTGOING.ID = @messID
		
		update MSG_FILENOTIFICATIONS_OUT set S_S = 1000180 /*sent*/, SENTDATE = getdate(), MSGID = @messID  where MSG_FILENOTIFICATIONS_OUT.ID in (select ID from @lines)
       
      end
    
    end
	
	set nocount off	
END