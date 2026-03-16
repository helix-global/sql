CREATE PROCEDURE [dbo].[SM_SLA_NOTIFY] @UserID int, @aMode int
AS
BEGIN
  set nocount on
  
  declare @now datetime = getdate()
  
  if datepart(hour,@now) < 17 or datepart(hour,@now) > 18 or dbo.COM_IS_WORKDAY(@now,1) = 0
  begin
    set nocount off
    return
  end
  
  declare @nowd date = cast(@now as date)
    
  declare @slasv table (SLAID int not null
                        , CALLID int not null
                        , SLA_VALUE decimal(12,2)
                        , REAL_VALUE decimal(12,2)
                        , VALUETYPE nvarchar(50)
                        , MODE int
                        , RECSTATE nvarchar(30))
  
  --Сервис-коллы: неотвеченные, у которых на текущий момент превышен срок SLA (отсылаются каждый день)
    insert into @slasv(SLAID,CALLID,SLA_VALUE,REAL_VALUE,VALUETYPE,MODE,RECSTATE )
    select A.ID,C.ID, A.FIRST_REACT_T * 60, datediff(mi, C.S_CDT, getdate()), 'First Reaction Time',1,'No Reply'
        from SM_SLA A with (nolock) 
            cross apply dbo.SM_CALLS_BY_SLA(A.ID,A.DEPID,A.MTID,A.CUSTID,A.MODELID) B
            left join SM_SERVICECALL C with (nolock) on C.ID = B.ID
        where C.SCDIRECTION = 1 /*incoming*/
            and C.SCTYPE = 2 /*email*/  
            /*TODO как быть с входящими звонками - не считать же что обязательно требуется ответный исходящий */
            /*TODO как быть с исходящими звонками в ответ на входящее письмо*/
            and not exists (select N.ID from SM_SERVICECALL N with (nolock) where N.REPLY2ID = C.ID)
            and datediff(hour, C.S_CDT, getdate()) > A.FIRST_REACT_T 
            and not exists (select * from SM_SLA_LASTNOTIFICATION LL where LL.SLAID = A.ID and LL.RECID=C.ID and LL.NOTIFYDATE >= @nowd and LL.MODE=1)
            
  --Сервис-коллы: отвеченные, у которых разница между датой создания и датой ответа больше срока в SLA (отсылаются один раз)
    insert into @slasv(SLAID,CALLID,SLA_VALUE,REAL_VALUE,VALUETYPE,MODE,RECSTATE)
    select A.ID,C.ID, A.FIRST_REACT_T * 60, datediff(mi, C.S_CDT, C.SENT_DT), 'First Reaction Time',1,'Replied'
        from SM_SLA A with (nolock) 
            cross apply dbo.SM_CALLS_BY_SLA(A.ID,A.DEPID,A.MTID,A.CUSTID,A.MODELID) B
            left join SM_SERVICECALL C with (nolock) on C.ID = B.ID
        where C.SCDIRECTION = 1 /*incoming*/
            and C.SCTYPE = 2 /*email*/  
            and exists (select N.ID from SM_SERVICECALL N with (nolock) where N.REPLY2ID = C.ID)
            and C.SENT_DT is not null
            and datediff(hour, C.S_CDT, C.SENT_DT) > A.FIRST_REACT_T 
            and not exists (select * from SM_SLA_LASTNOTIFICATION LL where LL.SLAID = A.ID and LL.RECID=C.ID and LL.MODE=1)

    --Сервис-кейсы: у которых сервисные заказы в работе и превышен срок закрытия SLA (отсылаются каждый день)
    insert into @slasv(SLAID,CALLID,SLA_VALUE,REAL_VALUE,VALUETYPE,MODE,RECSTATE)
    select A.ID, B.ID, A.SERV_ORD_RES_T * 60,datediff(mi, R.SERV_ORDER_IN_PROGRESS_DT, getdate()), 'Service Order Resolution Time',3, 'In Progress'
        from SM_SLA A with (nolock) 
            cross apply dbo.SM_CASES_BY_SLA(A.DEPID,A.MTID,A.CUSTID,A.MODELID) B
            left join SM_SERVICECASE CS with (nolock) on B.ID=CS.ID
            left join PR_PRORDER R  with (nolock) on CS.SERVORDID=R.ID
        where R.SERV_ORDER_IN_PROGRESS_DT is not null and datediff(hour, R.SERV_ORDER_IN_PROGRESS_DT, getdate()) > A.SERV_ORD_RES_T
                and R.S_S = 1000035 /*In Progress*/
                and not exists (select * from SM_SLA_LASTNOTIFICATION LL where LL.SLAID = A.ID and LL.RECID=B.ID and LL.NOTIFYDATE >= @nowd and LL.MODE=3)

    --Сервис-кейсы: у которых сервисные заказы завершены, но разница между датой перевода в работу и датой закрытия превысил срок SLA (отсылаются один раз)
    insert into @slasv(SLAID,CALLID,SLA_VALUE,REAL_VALUE,VALUETYPE,MODE,RECSTATE)
    select A.ID, B.ID, A.SERV_ORD_RES_T * 60,datediff(mi, R.SERV_ORDER_IN_PROGRESS_DT, R.COMPLETED_DT), 'Service Order Resolution Time',3,'Completed'
        from SM_SLA A with (nolock) 
            cross apply dbo.SM_CASES_BY_SLA(A.DEPID,A.MTID,A.CUSTID,A.MODELID) B
            left join SM_SERVICECASE CS with (nolock) on B.ID=CS.ID
            left join PR_PRORDER R  with (nolock) on CS.SERVORDID=R.ID
        where R.SERV_ORDER_IN_PROGRESS_DT is not null and datediff(hour, R.SERV_ORDER_IN_PROGRESS_DT, R.COMPLETED_DT) > A.SERV_ORD_RES_T
                and R.S_S = 1000036 /*Completed*/
                and not exists (select * from SM_SLA_LASTNOTIFICATION LL where LL.SLAID = A.ID and LL.RECID=B.ID and LL.MODE=3)
  
     declare @slaid int--, @mode int

    declare nxx cursor local read_only for 
    select distinct SLAID from @slasv 
    open nxx 
    WHILE 1=1
    BEGIN
        FETCH NEXT FROM nxx INTO @slaid;
        IF @@FETCH_STATUS<>0 BREAK;

        declare @to nvarchar(1024)
        set @to = null
        select @to = isnull(@to,'')+B.EMAIL+';'
        from SM_SLA_VIOLATION_EMAILS A with (nolock)
        left join COM_EMPLOYEE B on B.ID = A.EMPLID
        where A.VNESHID = @slaid
          and B.EMAIL is not null
          
          
        declare @mess nvarchar(max)
        set @mess = ''
        
        declare @tbl1 nvarchar(max) = ''
        declare @tbl2 nvarchar(max) = ''
        
        declare @header nvarchar(max) = ''
        set @header = 'Dear All,<br><br>Please find below information about SLA violation in service module:<br><br>'
        
        select @header = @header + 'Department: <b>'+isnull(JJ.NAME,'NA')
                         +'</b><br>Model Type: <b>'+isnull(KK.NAME,'NA')
                         +'</b><br>Customer: <b>'+isnull(LL.NAME,'*')
                         +'</b><br>Model: <b>'+isnull(ZZ.NAME,'*')
                         +'</b>'
        from SM_SLA A with (nolock) 
            left join COM_DEPARTMENTS JJ with (nolock) on JJ.ID = A.DEPID 
            left join PR_MODELTYPE KK with (nolock) on KK.ID = A.MTID 
            left join COM_CUSTOMER LL with (nolock) on LL.ID = A.CUSTID
            left join PR_MODELS ZZ with (nolock) on ZZ.ID = A.MODELID
        where A.ID = @slaid

        --Формирование таблицы по сервис-коллам
        set @tbl1 = @tbl1 + '<br><br>First Reaction Time'
        set @tbl1 = @tbl1 + '<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#fefefe" border="1" bordercolor="#000">'
        set @tbl1 = @tbl1 + '<tr><th>Service Call ID</th>' + 
            '<th>Subj</th>' + 
            '<th>Requestor</th>' + 
            '<th>Incoming Date</th>' + 
            '<th>SLA Value</th>' + 
            '<th>Current Value</th>' + 
            '<th>Current Call State</th></tr>'
        declare @tbl1content nvarchar(max) = ''
        select @tbl1content = @tbl1content+'<tr><td><a href = "a2l:\\Link=doc.sm_service_call.'+LTRIM(rtrim(str(B.ID)))+'">'+str(B.ID)+'</a>' + 
            '<td>'+B.SUBJ+'</td>' + 
            '<td>'+isnull(D.NAME,'NA')+'</td>' + 
            '<td>'+convert(nvarchar,B.S_CDT)+'</td>' + 
            '<td>'+dbo.COM_FORMAT_DHM(A.SLA_VALUE,1)+'</td>' + 
            '<td>'+dbo.COM_FORMAT_DHM(A.REAL_VALUE,1)+'</td>' + 
            '<td>'+A.RECSTATE+'</td></tr>'
        from @slasv A
            left join SM_SERVICECALL B with (nolock) on B.ID = A.CALLID
            left join SM_SERVICECASE C with (nolock) on C.ID = B.CASEID
            left join COM_CUSTOMER D with (nolock) on D.ID = C.CUSTID 
        where A.SLAID = @slaid and A.MODE=1
        order by B.ID desc

        set @tbl1 = @tbl1 + @tbl1content + '</table></font>'

        if @tbl1content = '' 
            set @tbl1 = ''

        --Формирование таблицы по сервис-кейсам
        set @tbl2 = @tbl2 + '<br><br>Service Order Resolution Time'
        set @tbl2 = @tbl2 + '<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#fefefe" border="1" bordercolor="#000">'
        set @tbl2 = @tbl2 + '<tr><th>Service Case</th>' + 
            '<th>Service Order</th>' + 
            '<th>Requestor</th>' + 
            '<th>Order Date</th>' + 
            '<th>Planned Date</th>' + 
            '<th>Service Order Proceed Date</th>' + 
            '<th>SLA Value</th>' + 
            '<th>Current Value</th>' + 
            '<th>Current Order State</th></tr>'
            
        declare @tbl2content nvarchar(max) = ''
        select @tbl2content = @tbl2content+'<tr><td><a href = "a2l:\\Link=doc.sm_service_case.'+LTRIM(rtrim(str(C.ID)))+'">'+isnull(C.ND,'NA')+'</a></td>' + 
            '<td>'+case when isnull(P.NN,'NA')='NA' then 'NA' else '<a href = "a2l:\\Link=doc.pr_service_order.'+LTRIM(rtrim(str(P.ID)))+'">'+P.NN+'</a>' end + '</td>' + 
            '<td>'+isnull(D.NAME,'NA')+'</td>' + 
            '<td>'+isnull(convert(nvarchar,P.DD),'')+'</td>' + 
            '<td>'+isnull(convert(nvarchar,P.EXPDATE),'')+'</td>' + 
            '<td>'+isnull(convert(nvarchar,P.SERV_ORDER_IN_PROGRESS_DT),'')+'</td>' + 
            '<td>'+dbo.COM_FORMAT_DHM(A.SLA_VALUE,1)+'</td>' + 
            '<td>'+dbo.COM_FORMAT_DHM(A.REAL_VALUE,1)+'</td>' + 
            '<td>'+A.RECSTATE+'</td></tr>'
        from @slasv A
            left join SM_SERVICECASE C with (nolock) on C.ID = A.CALLID
            left join PR_PRORDER P with (nolock) on C.SERVORDID=P.ID
            left join COM_CUSTOMER D with (nolock) on D.ID = C.CUSTID 
        where A.SLAID = @slaid and A.MODE=3
        order by C.ID desc

        set @tbl2 = @tbl2 + @tbl2content + '</table></font>'

            
        if @tbl2content = '' 
            set @tbl2 = ''


        set @mess = @mess + @header + @tbl1 + @tbl2

        set @mess = @mess + '<br><br>Production Database.'
        
        exec MSG_SEND @UserID, @to, null, 'SLA violation report', @mess

        --Запись в таблицу истории, чтобы не отсылать по отвеченным сервис-коллам и завершенным заказам несколько раз

        set @now = getdate()

        insert into SM_SLA_LASTNOTIFICATION (SLAID,NOTIFYDATE,MODE,RECID) 
        select distinct A.SLAID, @now, 1, B.ID
            from @slasv A
                left join SM_SERVICECALL B with (nolock) on B.ID = A.CALLID
                left join SM_SERVICECASE C with (nolock) on C.ID = B.CASEID
                left join COM_CUSTOMER D with (nolock) on D.ID = C.CUSTID 
            where A.SLAID = @slaid and A.MODE=1
            order by B.ID desc

        
        insert into SM_SLA_LASTNOTIFICATION (SLAID,NOTIFYDATE,MODE,RECID) 
        select distinct A.SLAID, @now, 3, C.ID
            from @slasv A
                left join SM_SERVICECASE C with (nolock) on C.ID = A.CALLID
                left join PR_PRORDER P with (nolock) on C.SERVORDID=P.ID
                left join COM_CUSTOMER D with (nolock) on D.ID = C.CUSTID 
            where A.SLAID = @slaid and A.MODE=3
            order by C.ID desc
           
    END
    close nxx;
    deallocate nxx;




    
  set nocount off
END