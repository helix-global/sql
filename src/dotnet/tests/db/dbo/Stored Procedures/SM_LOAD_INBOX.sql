CREATE PROCEDURE [dbo].[SM_LOAD_INBOX] @UserID int, @aMode int
AS
BEGIN
set nocount on

	declare @ids table (ID int not null, CUSTOMERID int)
	insert into @ids (ID)
	select A.ID from SM_INBOX A with (nolock) where A.S_S = 1

	update SM_INBOX set CONTACTID = (select top 1 A.ID from COM_CUST_CONTACTS A with (nolock) where upper(A.EMAIL) = upper(SM_INBOX.MSGFROM) and A.S_S = 1)
	where SM_INBOX.ID in (select ID from @ids)
	  and (select count(distinct CUSTOMERID) from COM_CUST_CONTACTS B with (nolock) where upper(B.EMAIL) = upper(SM_INBOX.MSGFROM) and B.S_S = 1) = 1 

	insert into SM_SERVICECALL (GID,SDEPID,DD,S_CR,S_CDT,SCTYPE,SCDIRECTION,SUBJ,SCBODY,MSGID,CUSTID,UNREAD,NEWSERVCASE,CASEID,MSGPLAINTEXT,EXCLUDEFROMSR,HIGHLIGHT)
	select newid(),C.DEPID,getdate(),@UserID,getdate(),2,1,isnull(A.MSGSUBJ,'-'),A.MSGBODY,A.ID,B.CUSTOMERID,1,0,dbo.SM_FINDCASEID(A.MSGSUBJ,B.CUSTOMERID),A.PLAINTEXT,0,0
	from SM_INBOX A with (nolock) 
	left join COM_CUST_CONTACTS B with (nolock) on B.ID = A.CONTACTID
	left join SM_EMAIL_BOXES C with (nolock) on C.ID = A.BOXID
	where A.ID in (select ID from @ids)
	
	/*23.03.2020 если case от другого подразделения, поменять на него т.к. может что письмо пришло после смены подразделения case*/
	update B set B.SDEPID = C.SDEPID
    from SM_SERVICECALL B 
    left join SM_SERVICECASE C with (nolock) on C.ID = B.CASEID
    where B.MSGID in (select ID from @ids)
      and B.CASEID is not null
      and C.SDEPID is not null
      and B.SDEPID <> C.SDEPID 

    /* от кого пришло */
	
	insert into SM_SERVICE_CALL_T (GID,S_CR,S_CDT,VNESHID,CNTID,USEASCOPY)
	select newid(),@UserID,getdate(),B.ID,A.CONTACTID,0
	from SM_INBOX A with (nolock) 
	left join SM_SERVICECALL B with (nolock) on B.MSGID = A.ID
	where A.ID in (select ID from @ids)
	  and A.CONTACTID is not null 


    /* по каждому service call добавить таблицу внешних и внутренних контактов
       контакт, от которого пришло, тут уже обработан. */
    
    /* 1 внешн: */
    insert into SM_SERVICE_CALL_T (GID,S_CR,S_CDT,VNESHID,CNTID,USEASCOPY)
	select newid(),@UserID,getdate(),B.ID,D.CONTACTID,D.USEASCOPY
	from SM_INBOX A with (nolock) 
	left join SM_SERVICECALL B with (nolock) on B.MSGID = A.ID
	cross apply dbo.SM_CONVERT_ADDRESSES_EXT(B.ID,B.CUSTID,A.MSGFROM,A.MSGTORAW,''/*A.MSGCCRAW*/) D
	where A.ID in (select ID from @ids)
	  and D.CONTACTID is not null 
	  
  
	/*KB514*/  
    insert into SM_SERVICE_CALL_T_CC (GID,S_CR,S_CDT,VNESHID,CNTID)
	select newid(),@UserID,getdate(),B.ID,D.CONTACTID
	from SM_INBOX A with (nolock) 
	left join SM_SERVICECALL B with (nolock) on B.MSGID = A.ID
	cross apply dbo.SM_CONVERT_ADDRESSES_EXT(B.ID,B.CUSTID,A.MSGFROM,''/*A.MSGTORAW*/,A.MSGCCRAW) D
	where A.ID in (select ID from @ids)
	  and D.CONTACTID is not null 	  
    
    /* 2 внутр: */
    insert into SM_SERVICE_CALL_TINT (GID,S_CR,S_CDT,VNESHID,UID,EMAIL,NAME)
	select newid(),@UserID,getdate(),B.ID,'RECIEVED',D.EMAIL,D.NAME
	from SM_INBOX A with (nolock) 
	left join SM_SERVICECALL B with (nolock) on B.MSGID = A.ID
	cross apply dbo.SM_CONVERT_ADDRESSES_INT(B.ID,A.MSGFROM,A.MSGTORAW,''/*A.MSGCCRAW*/) D
	where A.ID in (select ID from @ids)
	  and D.EMAIL is not null 
	  and D.EMAIL not in (select EMAIL from SM_EMAIL_BOXES with (nolock))
	  

	/*KB514*/  	  
    insert into SM_SERVICE_CALL_TINT_CC (GID,S_CR,S_CDT,VNESHID,UID,EMAIL,NAME)
	select newid(),@UserID,getdate(),B.ID,'RECIEVED',D.EMAIL,D.NAME
	from SM_INBOX A with (nolock) 
	left join SM_SERVICECALL B with (nolock) on B.MSGID = A.ID
	cross apply dbo.SM_CONVERT_ADDRESSES_INT(B.ID,A.MSGFROM,''/*A.MSGTORAW*/,A.MSGCCRAW) D
	where A.ID in (select ID from @ids)
	  and D.EMAIL is not null 
	  and D.EMAIL not in (select EMAIL from SM_EMAIL_BOXES with (nolock))	  


	insert into SM_SERVICECALL_FILES (GID,S_CR,S_CDT,VNESHID,FILENAME,FILEBLOB,FILEDATE,FILESIZE)
	select newid(),@UserID,getdate(),B.ID,A.FILENAME,A.FILEBLOB,A.FILEDATE,A.FILESIZE
	from SM_IN_ATTACHEMENTS A with (nolock) 
	left join SM_SERVICECALL B with (nolock) on B.MSGID = A.VNESHID
	where A.VNESHID in (select ID from @ids)


    update SM_INBOX set S_S = 1000204/*processed*/ where ID in (select ID from @ids)
    
    insert into SM_OUTGOING (GID, S_S, S_CR, S_CDT, MSGTO, MSGSUBJ, MSGBODY, BOXID, SERVICECALLID)
    select newid(),1,@UserID,getdate(),A.MSGFROM, C.AUTOREPLYSUBJ, C.AUTOREPLYHTML, A.BOXID, D.ID
    from SM_INBOX A with (nolock) 
    left join SM_EMAIL_BOXES C with (nolock) on C.ID = A.BOXID
    left join SM_SERVICECALL D with (nolock) on D.MSGID = A.ID
    where A.ID in (select ID from @ids)
      and C.AUTOREPLY = 1
      and A.MSGSUBJ not like '%##%##%'
    
    
    update SM_SERVICECASE set WAITRESPONSE_FLAG = dbo.SM_SERVICECASE_WAITING4RESPONSE(SM_SERVICECASE.ID) 
    where SM_SERVICECASE.ID in (select B.CASEID
                   from SM_SERVICECALL B with (nolock)
                  where B.MSGID in (select ID from @ids))  
                  
    update SM_SERVICECASE set S_S = 1000191 
     where SM_SERVICECASE.ID in (select B.CASEID
                   from SM_SERVICECALL B with (nolock)
                  where B.MSGID in (select ID from @ids))  
           and SM_SERVICECASE.S_S = 1000192                  
    
set nocount off
END