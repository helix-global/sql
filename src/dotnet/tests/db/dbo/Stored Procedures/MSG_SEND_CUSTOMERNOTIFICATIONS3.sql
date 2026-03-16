CREATE PROCEDURE [dbo].[MSG_SEND_CUSTOMERNOTIFICATIONS3] @aUserID int
AS
BEGIN
/*
   версия 2 посылает несколько строк по одной подписке из MSG_FILENOTIFICATIONS_OUT одним письмом
   
   версия 3 обрабатывает вставки: 
   <SNs> 
   <ModelName,SN,SO table> 
   <ModelName,SN table>
   <ModelName,SN,SO table,Ticket>   
   
   04.06.18 добавлен лимит размера одного письма 7MB

   21.09.23 KB4291 Efimov 
   обрабатывает вставку
   <ModelName,SN,SO table,CustRefNo,Ticket>

*/
    set nocount on

    declare @now datetime
    set @now = getdate()
    
    if not exists (select A.ID 
                     from MSG_FILENOTIFICATIONS_OUT A with (nolock)
                left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
                    where A.S_S = 1000183/*ready to sent*/
                      and B.S_S = 1000176 /*approved*/  )
    begin
      set nocount off
      return
    end
    
    
    declare @messID int
    declare @lines table(ID int not null,ROWID int not null identity,FILESIZE_KB decimal(20,2))
    declare @subscrID int
    declare @subscrCustomerID int
    declare @i int = 0
    declare @sns nvarchar(max) 
    declare @table1 nvarchar(max) 
    declare @table2 nvarchar(max) 
    declare @table3 nvarchar(max) 
	declare @table4 nvarchar(max) /* KB4291 */
    declare @ticketURL nvarchar(200)
    declare @cbscrTType int
    
    declare @ticketlines table(ID int not null,TICKETID int,NEWEXPIRED datetime)
    
    /* 1 выкладка тикетов (здесь записываются файлы и меняется состояние тикета, затем служба выложит это на WEB Server) */
    insert into @ticketlines (ID, TICKETID, NEWEXPIRED)
    select A.ID 
          ,(select top 1 B.ID from CP_TICKETS B with (nolock) where B.DEVICEID = A.DEVICEID and B.AUTOCREATED = 1 and B.S_S in (2000005,2130007)/*reserved, miss.files*/) as TICKETID
          ,dateadd(day,isnull(B.TICKETEXP,10),getdate()) as EXPIRED
    from MSG_FILENOTIFICATIONS_OUT A with (nolock)
    left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
    where A.S_S = 1000183 /*ready to sent*/ 
      and B.S_S = 1000176 /*approved*/
	  and B.STYPE in (2,3) /*with tickets*/
	  and exists (select K.ID from MSG_FILENOTIFICATIONS_OUT_FILES K with(nolock) where K.VNESHID = A.ID)

    update MSG_FILENOTIFICATIONS_OUT set TICKETID = (select B.TICKETID from @ticketlines B where B.ID = MSG_FILENOTIFICATIONS_OUT.ID)
    where MSG_FILENOTIFICATIONS_OUT.ID in (select ID from @ticketlines)
    
    delete from CP_TICKET_ATTACHEMENTS where VNESHID in (select C.TICKETID from @ticketlines C where C.TICKETID is not null)
       and not exists (select KK.ID from MSG_FILENOTIFICATIONS_OUT_FILES KK with (nolock) where KK.ID = CP_TICKET_ATTACHEMENTS.NOTY_OUT_FILEID)

    declare @changedFiles table (ID int not null, NOTY_OUT_FILEID int not null)
    insert into @changedFiles (ID, NOTY_OUT_FILEID)
    select A.ID, A.NOTY_OUT_FILEID
    from CP_TICKET_ATTACHEMENTS A with (nolock)
    left join MSG_FILENOTIFICATIONS_OUT_FILES B with (nolock) on B.ID = A.NOTY_OUT_FILEID
    where A.VNESHID in (select C.TICKETID from @ticketlines C where C.TICKETID is not null)
      and A.NOTY_OUT_FILEID is not null
      and (A.FILEDATE <> B.FILEDATE or A.FILESIZE <> B.FILESIZE or A.FILENAME <> B.FILENAME)
      
    delete from CP_TICKET_ATTACHEMENTS where ID in (select ID from @changedFiles)

/*
    delete from CP_TICKET_ATTACHEMENTS where VNESHID in (select C.TICKETID from @ticketlines C where C.TICKETID is not null)
       and (select KK.FILEDATE from MSG_FILENOTIFICATIONS_OUT_FILES KK with (nolock) where KK.ID = CP_TICKET_ATTACHEMENTS.NOTY_OUT_FILEID) <> CP_TICKET_ATTACHEMENTS.FILEDATE
*/       
    
    insert into CP_TICKET_ATTACHEMENTS (GID,S_CR,S_CDT,VNESHID,NOTY_OUT_FILEID,FILENAME,FILEDATE,FILESIZE,FILEBLOB,FILEDESC)
    select newid(),@aUserID,getdate(),A.TICKETID,B.ID,B.FILENAME,B.FILEDATE,B.FILESIZE,B.FILEBLOB,null /*TODO что в описание записать*/
    from @ticketlines A
    left join MSG_FILENOTIFICATIONS_OUT_FILES B with (nolock) on B.VNESHID = A.ID
    where A.TICKETID is not null
      and not exists (select KK.ID from CP_TICKET_ATTACHEMENTS KK with (nolock) where KK.VNESHID = A.TICKETID and KK.NOTY_OUT_FILEID = B.ID)
    
    update CP_TICKETS set S_S = 1
          ,EXPIRED = (select top 1 B.NEWEXPIRED from @ticketlines B where B.TICKETID = CP_TICKETS.ID)
    where CP_TICKETS.ID in (select C.TICKETID from @ticketlines C where C.TICKETID is not null)
		 
		 /* Заплатка на письмо от Марата Гумерова от 31-07-2023
			@ticketlines TicketID = 138796 возвращал EXPIRED = NULL
		 */
		 --and (select top 1 B.NEWEXPIRED from @ticketlines B where B.TICKETID = CP_TICKETS.ID) is not null
    
    /*1.1 перевод reserved тикетов в missing files по таким записям в MSG_FILENOTIFICATIONS_OUT*/
    declare @missftab table (ID int not null,TICKETID int)
    insert into @missftab (ID, TICKETID)
    select A.ID 
          ,(select top 1 B.ID from CP_TICKETS B with (nolock) where B.DEVICEID = A.DEVICEID and B.AUTOCREATED = 1 and B.S_S = 2000005/*reserved*/) as TICKETID
    from MSG_FILENOTIFICATIONS_OUT A with (nolock)
    left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
    where A.S_S = 1000184 /*missing files*/ 
      and B.S_S = 1000176 /*approved*/
	  and B.STYPE in (2,3) /*with tickets*/

    update MSG_FILENOTIFICATIONS_OUT set TICKETID = (select B.TICKETID from @missftab B where B.ID = MSG_FILENOTIFICATIONS_OUT.ID)
    where MSG_FILENOTIFICATIONS_OUT.ID in (select G.ID from @missftab G where G.TICKETID is not null)
      and MSG_FILENOTIFICATIONS_OUT.TICKETID is null
    
    update CP_TICKETS set S_S = 2130007 /*miss files*/
    where ID in (select G.TICKETID from @missftab G where G.TICKETID is not null)
      and S_S = 2000005 /*reserved*/
    
    set @ticketURL = dbo.DEF_SYS_CONST_STR('cp_portal_ticket_link_mask', null)
    
    /* 2 оправка писем */
    while (@i < 12)
    begin
      set @i = @i + 1
    
      delete from @lines
      set @subscrID = null
      set @subscrCustomerID = null
      set @cbscrTType = 0
       
      select top 1 @subscrID = A.SBSCID
                 , @subscrCustomerID = A.CUSTOMERID
                 , @cbscrTType = isnull(B.STYPE,0)
	  from MSG_FILENOTIFICATIONS_OUT A with (nolock) 
	  left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
	 where A.S_S = 1000183/*ready to sent*/ 
	   and dateadd(hour,B.SENDDELAY,A.READYDT) <= @now /*вышло время задержки*/ 
	   and B.S_S = 1000176 /*approved*/
	   and B.STYPE in (1,3) /*with email*/
      
      if @subscrID is null or @subscrCustomerID is null break;
       
      insert into @lines (ID, FILESIZE_KB)
      select A.ID
           ,(select sum(D.FILESIZE/1024) from MSG_FILENOTIFICATIONS_OUT_FILES D with (nolock) where D.VNESHID = A.ID) as KB
      from MSG_FILENOTIFICATIONS_OUT A with (nolock) 
	  left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
	 where A.S_S = 1000183/*ready to sent*/ 
	   and A.SBSCID = @subscrID
	   and A.CUSTOMERID = @subscrCustomerID
	   and dateadd(hour,B.SENDDELAY,A.READYDT) <= @now /*вышло время задержки*/ 
	   and B.S_S = 1000176 /*approved*/
	   and B.STYPE in (1,3) /*with email*/

      if exists (select * from @lines)
      begin

        /* убираются строки при превышении 5 MB - они обработаются в следующий заход */ 
        if @cbscrTType = 1
        begin
			delete from @lines 
			where (select sum(isnull(B.FILESIZE_KB,0)) from @lines B where B.ROWID <= "@lines".ROWID) > 5*1024
			  and ROWID > (select min(L.ROWID) from @lines L) /*первая строка должна остаться*/
	    end
        
        set @sns = null
        set @table1 = null
        set @table2 = null
        set @table3 = null
		set @table4 = null
        
        select @sns = isnull(@sns,'') + isnull(C.SN,'NA')+','
              ,@table1 = isnull(@table1,'') + '<tr><td>'+isnull(D.NAME,'NA')+'</td><td>'+isnull(C.SN,'NA')+'</td><td>'+isnull(dbo.COM_EXTR_WORD(B.READYNAVMSG,5,';'),'NA')+'</td></tr>'
              ,@table2 = isnull(@table2,'') + '<tr><td>'+isnull(D.NAME,'NA')+'</td><td>'+isnull(C.SN,'NA')+'</td></tr>'
              ,@table3 = isnull(@table3,'') + '<tr><td>'+isnull(D.NAME,'NA')+'</td><td>'+isnull(C.SN,'NA')+'</td><td>'+isnull(dbo.COM_EXTR_WORD(B.READYNAVMSG,5,';'),'NA')+'</td><td>'+dbo.MSG_TICKET_URL_HTML(@ticketURL,B.DEVICEID)+'</td></tr>'
			  /* KB4291 */
			  ,@table4 = isnull(@table4,'') + '<tr><td>'+isnull(D.NAME,'NA')+'</td><td>'+isnull(C.SN,'NA')+'</td><td>'+isnull(dbo.COM_EXTR_WORD(B.READYNAVMSG,5,';'),'NA')+'</td><td>'+isnull(dbo.COM_EXTR_WORD(B.READYNAVMSG,6,';'),'NA')+'</td><td>'+dbo.MSG_TICKET_URL_HTML(@ticketURL,B.DEVICEID)+'</td></tr>' 
        from @lines A
        left join MSG_FILENOTIFICATIONS_OUT B with (nolock) on B.ID = A.ID
        left join PR_DEVICE C with (nolock) on C.ID = B.DEVICEID
        left join PR_MODELS D with (nolock) on D.ID = C.MODELID
        
        set @sns = isnull(@sns,'NA')
        if @sns like '%,'
          set @sns = substring(@sns,0,len(@sns))
         
        set @table1 = '<tr><th>Model</th><th>Serial Number</th><th>Order Reference</th></tr>'+isnull(@table1,'') 
        set @table2 = '<tr><th>Model</th><th>Serial Number</th></tr>'+isnull(@table2,'') 
        set @table3 = '<tr><th>Model</th><th>Serial Number</th><th>Order Reference</th><th>Documents Link</th></tr>'+isnull(@table3,'') 
        /* KB4291 */ 
		set @table4 = '<tr><th>Model</th><th>Serial Number</th><th>Order Reference</th><th>Customer Order Reference</th><th>Documents Link</th></tr>'+isnull(@table4,'') 

        declare @msSubj nvarchar(1024)
        declare @msBody nvarchar(max)
        declare @msTo nvarchar(1024)
        
        select @msSubj = B.SUBJ
              ,@msBody = B.MSG
        from MSG_FILENOTIFICATIONS B with (nolock) 
        where B.ID = @subscrID
        
        set @msTo = dbo.MSG_FILENOTIFICATION_TO(@subscrID, @subscrCustomerID)
         
        set @msSubj = replace(@msSubj,'<SNs>',@sns) 

        set @msBody = replace(@msBody,'<SNs>',@sns) 
        set @msBody = replace(@msBody,'<ModelName,SN,SO table>',@table1) 
        set @msBody = replace(@msBody,'<ModelName,SN table>',@table2) 
        set @msBody = replace(@msBody,'<ModelName,SN,SO table,Ticket>',@table3) 
		/* KB4291 */
		set @msBody = replace(@msBody,'<ModelName,SN,SO table,CustRefNo,Ticket>',@table4)  
		
         
        set @messID = null 
		
		INSERT INTO MSG_OUTGOING (S_S, GID, MSGTO, MSGCC, MSGSUBJ, MSGBODY, S_CDT, S_CR, CUSTOMERSUBSCRID ,MSGBCC, CUSTOMERID, SEND_AFTER_DT ) 
		select 0,newid(),@msTo,B.CC,@msSubj,@msBody,getdate(),@aUserID, B.ID, B.BCC, @subscrCustomerID, dateadd(hour,1,getdate())
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