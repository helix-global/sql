

CREATE PROCEDURE [dbo].[VR_MSG_MD_DAILY_REPORT] 
  @aUserID int
AS
BEGIN


	/* KB4940 16.09.2024 Efimov - Daily Visitor requests report */
	/* KB5006 26.09.2024 Efimov - logging text of e-mail body */
	/* KB5017 07.10.2024 Efimov - format STYLE */
	
	declare @REPORTTIME time = '06:00'	-- Report create and send time
	declare @DELIVERYTYPE int = 44090 /* non-existent delivery type - for delivery to VRMD group user */
	
	declare @DELIVERYDEPID int = -1
	
	declare @nowDateTime datetime = getdate()
	declare @nowTIME time =  cast(@nowDateTime as time)
	declare @nowDATE date =  cast(@nowDateTime as date)
	
	declare @subj nvarchar(1000) = 'Daily Visitor requests report'
	declare @body nvarchar(max) = ''
	
	--select * from MSG_LAST_DELIVERY_DATES where  DELIVERYTYPE = @DELIVERYTYPE
	--delete from MSG_LAST_DELIVERY_DATES where  DELIVERYTYPE = 44089
	
	-- ############## ПРОВЕРКА НА РАБОЧИЕ ДНИ НЕДЕЛИ #########################################
	SET DATEFIRST 1
	
	if (DATEPART(dw,GETDATE()) in (6,7)) /* mon - fr */
	begin
	   print 'exit (need report only at friday)'
	   set nocount off
	   return
	end
	
	-- ################# ПРОВЕРКА НА УЖЕ ОТПРАВЛЕННЫЙ ОТЧЕТ ###########################################
	 if exists (select G.DD from MSG_LAST_DELIVERY_DATES G where G.DELIVERYTYPE = @DELIVERYTYPE and G.DEPID = @DELIVERYDEPID and G.DD = cast(@nowDATE as date))
	 begin
	   print 'exit (today already done)'
	   set nocount off
	   return
	 end
	
	-- ################# ПРОВЕРКА НАСТУПИЛО ЛИ ВРЕМЯ ДЛЯ ОТПРАВКИ НОВОГО ОТЧЕТ ########################################### 
	
	 print 'report send time: ' + CAST(@REPORTTIME as varchar(5))
	 print 'current time    : ' + cast(@nowTime as varchar(5))
	
	 if  @nowDateTime <= (CAST(@nowDATE as datetime) + CAST(@REPORTTIME as datetime)) 
	 begin
		print 'exit (it is not time to send)'
		set nocount off
	    return
	 end
		
	
	print CHAR(13) + 'TIME TO SEND REPORT !!!' + CHAR(13)
	
	
	
	
	
	/* REPORT => */
	
	
	
	
	declare @today date = getdate() --'20240910' --GetDate()
	declare @nl nvarchar(2) = CHAR(13)+ CHAR(10)
	
	declare @report nvarchar(max) = ''
	
	declare @table_today_customers nvarchar(max) = ''
	declare @table_today_ipgsubsidiaries nvarchar(max) = ''
	declare @table_today_other nvarchar(max) = ''
	
	/* !!!!!! monday first day of week !!!!!!! */
	SET DATEFIRST 1
	
	/* TODAY CUSTOMERS TABLE ############### */
	if exists(select * from [VR_REPORT_KB4940_TODAY](@today, 1))
	begin
		set @table_today_customers = @table_today_customers + '<p class="subreportCaption">Custromers</p><table class="today"><tr><th class="company">Company</th><th>Visitor Subtype</th><th>Visist Period</th><th>Department</th><th>Visitor Names</th></tr>' + @nl
		select 	@table_today_customers = @table_today_customers + '<tr><td><a href="' + LINK + '">' + COMPANY + '</a></td><td>' + VISITOR_SUBTYPE +'</td><td>' + VISIT_PERIOD +'</td><td>' + DEPARTMENT +'</td><td>' + VISITOR_NAMES +'</td></tr>'
		from [VR_REPORT_KB4940_TODAY](@today, 1)
		set @table_today_customers = @table_today_customers + '</table>'
		--select * from [VR_REPORT_KB4940_TODAY_CUSTOMERS](@today)
	end
	
	/* TODAY SUBSIDIARIES TABLE ############### */
	if exists(select * from [VR_REPORT_KB4940_TODAY](@today, 2))
	begin
		set @table_today_ipgsubsidiaries = @table_today_ipgsubsidiaries + '<p class="subreportCaption">IPG subsidiaries</p><table class="today"><tr><th class="company">Company</th><th>Visitor Type</th><th>Visist Period</th><th>Department</th><th>Visitor Names</th></tr>' + @nl
		select @table_today_ipgsubsidiaries = @table_today_ipgsubsidiaries + '<tr><td><a href="' + LINK + '">' + COMPANY + '</a></td><td>' + VISITOR_TYPE +'</td><td>' + VISIT_PERIOD +'</td><td>' + DEPARTMENT +'</td><td>' + VISITOR_NAMES +'</td></tr>'
		from [VR_REPORT_KB4940_TODAY](@today, 2)
		set @table_today_ipgsubsidiaries = @table_today_ipgsubsidiaries + '</table>'
		--select * from [VR_REPORT_KB4940_TODAY_CUSTOMERS](@today)
	end
	
	/* TODAY OTHER TABLE ############### */
	if exists(select * from [VR_REPORT_KB4940_TODAY](@today, 3))
	begin
		set @table_today_other = @table_today_other + '<p class="subreportCaption">Other</p><table class="today"><tr><th class="company">Company</th><th>Visitor Type</th><th>Visitor Subtype</th><th>Visist Period</th><th>Department</th><th>Visitor Names</th></tr>' + @nl
		select @table_today_other = @table_today_other + '<tr><td><a href="' + LINK + '">' + COMPANY + '</a></td><td>' + VISITOR_TYPE +'</td><td>' + VISITOR_SUBTYPE +'</td><td>' + VISIT_PERIOD +'</td><td>' + DEPARTMENT +'</td><td>' + VISITOR_NAMES +'</td></tr>'
		from [VR_REPORT_KB4940_TODAY](@today, 3)
		set @table_today_other = @table_today_other + '</table>'
		--select * from [VR_REPORT_KB4940_TODAY_OTHER](@today)
	end
	
	-- css style
	declare @style nvarchar(max) = '
	    <style>

        

        /* all document */
        body {
            font-family: "Calibri";
            font: Calibri;
        }

        h3 {
            color: rgb(13, 74, 131);
        }

		p.reportCaption {
            font-size: 16pt;
            font-weight: bold;
            color: rgb(13, 74, 131);
        }    

        p.subreportCaption {
            font-size: 12pt;
            font-weight: bold;
            color: rgb(13, 74, 131);
        }


        table {
            width: 1200px;
            border-color: rgb(200, 200, 200);
        }

        table,
        th,
        td {
            border: 1px solid rgb(200, 200, 200);
            border-collapse: collapse;
        }

        td {
            padding: 3px;
        }

        /* cell background colors depending visitor request state */
        table td.weekend {
            background-color: rgb(241, 241, 241);
        }

        table td.approved {
            background-color: rgb(228, 245, 210);
        }

        table td.mdpending {
            background-color: rgb(255, 230, 153);
        }

        /* today tables */
        table.today th {
            background-color: rgb(200, 200, 200);
            color: rgb(13, 74, 131);
            font-size: 11pt; 
            vertical-align: center;
            border: 1px solid white;
            border-collapse: collapse;
        }

        table.today tr {
            width: 100px;
            height: 30px;
            vertical-align: middle;
            padding: 5px;
            font-size: 11pt; 
        }

        table.today td {
            width: 200px;
        }

        th.company {
            width: 150px;
        }

        /* timeline tables */
        table.timeline th {
            background-color: rgb(200, 200, 200);
            color: rgb(13, 74, 131);
            font-size: medium;
            vertical-align: center;
            border: 1px solid white;
            border-collapse: collapse;
            font-size: 11pt; 
        }
        table.timeline tr {
            font-size: 10pt; 
        }

        th.day {
            padding: 2px;
            min-width: 70;
            width: auto;
        }

        /* table legend */
        table.legend {
            width: 350px;
            border: 2px;
            border-color: transparent;
            border-collapse: separate;
        }

        table.legend td {
            width: 50%;
            border-color: transparent;
        }

        p.signature {
            font-size: small;
        }
    </style>
'
	
	
	/* ############### FINAL REPORT ############### */
	set @report = @report + '<html> <head>'
	set @report = @report + @style
	set @report = @report + '</head>'
	set @report = @report + '<body>' + @nl
	
	
	
	--VISITORS TODAY
	set @report = @report + '<a href = "a2l:\\Link=doc.def_view.531"><p class="reportCaption">Visitors today</p><a>' + @nl
	
	set @report = @report + @table_today_customers + @nl
	set @report = @report + @table_today_ipgsubsidiaries + @nl
	set @report = @report + @table_today_other + @nl
	set @report = @report + '<br>'
	
	--TIMELINE
	set @report = @report + '<a href="a2l:\\Link=doc.def_view.525"><p class="reportCaption">Visitors timeline</p></a>' + @nl
	set @report = @report + '<table class="timeline">'
	set @report = @report + dbo.[VR_REPORT_KB4940_TIMELINE](@today , 1)
	set @report = @report + dbo.[VR_REPORT_KB4940_TIMELINE](@today , 2)
	set @report = @report + dbo.[VR_REPORT_KB4940_TIMELINE](@today , 3)
	set @report = @report + '</table>'
	
	--LEGEND
	set @report = @report +'<br>
	            <table class="legend">
	                <tr>
	                    <td>Approved Visit:</td>
	                    <td class="approved"></td>
	                </tr>
	                <tr>
	                    <td>Need to Approve Visit:</td>
	                    <td class="mdpending"></td>
	                </tr>
	                <tr>
	                    <td>Weekend:</td>
	                    <td class="weekend"></td>
	                </tr>
	            </table>'
	set @report = @report + '<br><p class="signature">Created: ' + SUBSTRING(convert(nvarchar(100), GETDATE(), 114),1,5) + ' ' + convert(nvarchar(100), GETDATE(), 104) +  '<br>'
	set @report = @report + 'by Production DataBase (PDB).<br>'
	set @report = @report + 'Please, do not answer.'
	set @report = @report + '</body>'
	set @report = @report + '</html>'
	
	set @body = @report
	
	--select @body
	

	/* KB5006 logging text of e-mail body*/
	insert into DEF_LOG (DD, LEV, CAPTION, S_USERID, EV_TEXT, DOCOID, DOCID, EV_TYPE, ADDINFO)
	values ( GETDATE(), 1, 'Create e-mail daily report "Daily Visitor requests report" with this body', @aUserID, @body, 0,0,0, @subj)

	
	exec  MSG_SEND_TOGROUP @aUserID, 44089 /*VRMD*/, @subj, @body
	
	
	/* <= REPORT */
	
	
	
	-- ############## ПОМЕЧАЕМ ЧТО СЕГОДНЯ ПИСЬМО ОТПРАВЛЕНО #########################################
	insert into MSG_LAST_DELIVERY_DATES (DELIVERYTYPE,DEPID,DD) values (@DELIVERYTYPE,@DELIVERYDEPID, @nowDate)
	print 'Report date is inserted in [MSG_LAST_DELIVERY_DATES].'



end