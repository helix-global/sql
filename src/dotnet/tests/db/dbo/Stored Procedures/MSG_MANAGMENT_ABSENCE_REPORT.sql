
/*
			KB2334 Отчет руководству об отсутсвии, утверждениях отсутсвия и отмены начальников департаментов
			KB2556 Добавление таблиц timeline
22.04.2024	KB4748 (Efimov)
*/

CREATE PROCEDURE [dbo].[MSG_MANAGMENT_ABSENCE_REPORT] @aUserID int
AS
BEGIN

set nocount on

--/* TEST DATA*/
--declare @aUSERID int = 26052 -- Efimov Maksim
--/* TEST DATA*/


declare @REPORTTIME time = '06:00' -- Report create and send time
declare @DELIVERYTYPE int = 2300 -- Notification about the absence of top management
declare @DELIVERYDEPID int = 283 -- IPGL
declare @SUBJ varchar(100) = 'Daily Employee absence report'

declare @nowDateTime datetime = getdate()
declare @nowTIME time =  cast(@nowDateTime as time)
declare @nowDATE date =  cast(@nowDateTime as date) 




-- ############## ПРОВЕРКА НА РАБОЧИЕ ДНИ НЕДЕЛИ #########################################

if ([dbo].[COM_IS_WORKDAY] (@nowDateTime,1) = 0)
begin
   print 'exit (nobody need report at weekends)'
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




-- ################# ПОДГОТАВЛИВАЕМ И ОТПРАВЛЯЕМ ОТЧЕТ ############################################

-- Собираем необходимых людей и данные по отсутсвиям по ним
declare @VACATION as table (ID int, S_CDT datetime ,PERIODSTR varchar(150), EMPLID int, EMPLNAME varchar(150), DBEG date, DEND date, VACATIONTYPE int, S_S int, PRODDEP int, S_S_NAME varchar(150), 
		PERIODTYPE int, SHORTSTART datetime, SHORTDURATION int, CANCELATION_S_S int, CANCELATION_ID int, VACATIONTYPENAME varchar(100));

insert into @VACATION
select * from [dbo].[COM_DEP_HEADS_VACATIONS]()
where PRODDEP in (1,2) -- Support and Prod departments in IPGL DE



-- переменные для хранения частей отчета (для табличной части <TR>)

declare @vacation_supdep_res as varchar(max)
declare @vacation_proddep_res as varchar(max)

declare @approve_vacation_supdep_res as varchar(max)
declare @approve_vacation_proddep_res as varchar(max)

declare @approve_cancelation_supdep_res as varchar(max)
declare @approve_cancelation_proddep_res as varchar(max)



-- ###################### ЗАПОЛНЕНИЕ ЧАСТЕЙ ОТЧЕТА (<TR>) #############################################################################################

-- Отсутсвуют сегодня Support Deps
set @vacation_supdep_res = (
	select 
		EMPLNAME + '</td><td><center>' + V.PERIODSTR + '</center><td><center>' + V.VACATIONTYPENAME + '</center>'  as td
	from 
		@VACATION V
	WHERE 
		V.PRODDEP  = 2								-- Supproted Department
		and V.S_S = 1000141							-- Approved
		and V.DBEG<= @nowDATE and V.DEND >= @nowDATE		-- Нужные даты
	order by V.EMPLNAME asc, V.DBEG ASC, cast(V.SHORTSTART as time) asc
	for xml path( 'tr' )
	
)
-- Отсутсвуют сегодня Production Deps
set @vacation_proddep_res = (
	select 
		EMPLNAME + '</td><td>' + V.PERIODSTR + '<td><center>' + V.VACATIONTYPENAME + '</center>'  as td
	from 
		@VACATION V
	WHERE 
		V.PRODDEP = 1								-- Production Department
		and V.S_S = 1000141							-- Approved
		and V.DBEG<= @nowDATE and V.DEND >= @nowDATE		-- Нужные даты
	order by V.EMPLNAME asc, V.DBEG ASC, cast(V.SHORTSTART as time) asc
	for xml path( 'tr' )
)

-- Заявки на утверждение Supporter Department
set @approve_vacation_supdep_res = (
	select 
		--EMPLNAME + '</td><td>' +  [dbo].[COM_FORMAT_DATETIME](V.DBEG,1) + '</td><td>' + [dbo].[COM_FORMAT_DATETIME](V.DEND,1) +  '</td><td>' + V.PERIODSTR + '</td><td>' + '<a href="a2l:\\Link=doc.com_vacation.' + ltrim(rtrim(str(V.ID))) + '">Open in PDB</a>' as td
		EMPLNAME + '</td><td>' +  V.PERIODSTR + '</td><td>' + '<center><a href="a2l:\\Link=doc.com_vacation.' + ltrim(rtrim(str(V.ID))) + '">Open in PDB</a></center>' as td
	from 
		@VACATION V
	WHERE 
		V.PRODDEP  = 2								-- Supproted Department
		and V.S_S = 1000140							-- NOT Approved
	order by V.EMPLNAME asc, V.DBEG ASC, cast(V.SHORTSTART as time) asc
	for xml path( 'tr' )
)

-- Заявки на утверждение Prod Department
set @approve_vacation_proddep_res = (
	select 
		--EMPLNAME + '</td><td>' +  [dbo].[COM_FORMAT_DATETIME](V.DBEG,1) + '</td><td>' + [dbo].[COM_FORMAT_DATETIME](V.DEND,1) +  '</td><td>' + V.PERIODSTR + '</td><td>' + '<a href="a2l:\\Link=doc.com_vacation.' + ltrim(rtrim(str(V.ID))) + '">Open in PDB</a>' as td
		EMPLNAME + '</td><td>' +  V.PERIODSTR + '</td><td>' + '<center><a href="a2l:\\Link=doc.com_vacation.' + ltrim(rtrim(str(V.ID))) + '">Open in PDB</a></center>' as td
	from 
		@VACATION V
	WHERE 
		V.PRODDEP  = 1								-- Production Department
		and V.S_S = 1000140							-- NOT Approved
	order by V.EMPLNAME asc, V.DBEG ASC, cast(V.SHORTSTART as time) asc
	for xml path( 'tr' )
)

-- Заявки на отмену Supporter Department
set @approve_cancelation_supdep_res = (
	select 
		EMPLNAME + '</td><td>' +  V.PERIODSTR + '</td><td>' + '<center><a href="a2l:\\Link=doc.com_vacation_cancel.' + ltrim(rtrim(str(V.CANCELATION_ID ))) + '">Open in PDB</a></center>' as td
	from 
		@VACATION V
	WHERE 
		V.PRODDEP  = 2								-- Supproted Department
		and V.CANCELATION_S_S = 1000162				-- Cancelation required
	order by V.EMPLNAME asc, V.DBEG ASC, cast(V.SHORTSTART as time) asc
	for xml path( 'tr' )
)

-- Заявки на утверждение сегодня Prod Department
set @approve_cancelation_proddep_res = (
	select 
		EMPLNAME + '</td><td>' +  V.PERIODSTR + '</td><td>' + '<center><a href="a2l:\\Link=doc.com_vacation_cancel.' + ltrim(rtrim(str(V.CANCELATION_ID ))) + '">Open in PDB</a></center>' as td
	from 
		@VACATION V
	WHERE 
		V.PRODDEP  = 1								-- Production Department
		and V.CANCELATION_S_S = 1000162				-- Cancelation required
	order by V.EMPLNAME asc, V.DBEG ASC, cast(V.SHORTSTART as time) asc
	for xml path( 'tr' )
)

--print 'vacation_supdep_res				' + @vacation_supdep_res
--print 'vacation_proddep_res				' + @vacation_proddep_res
--print 'shor_vacation_supdep_res			' + @shor_vacation_supdep_res
--print 'shor_vacation_proddep_res		' + @shor_vacation_proddep_res
--print 'approve_vacation_supdep_res		' + @approve_vacation_supdep_res
--print 'approve_vacation_proddep_res		' + @approve_vacation_proddep_res
--print 'approve_cancelation_supdep_res	' + @approve_cancelation_supdep_res 
--print 'approve_cancelation_proddep_res	' + @approve_cancelation_proddep_res


-- ###################### ГЕНЕРАЦИЯ HTML для ОТЧЕТА (сборка полученных <TR> в части отчета с готовыми <TABLE> и заголовками групп)#############################################################################################

declare @res varchar(max) = ''
declare @headerrow varchar(max) = '<th>Employee</th><th>Absence period</th>'

declare @SIZE_HEADER varchar(2) = 'H3';
declare @SIZE_GROUP  varchar(2) = 'H4';

declare @NORECORDS varchar(50) = '<DIV class="group_header">No records.</DIV>'

-- Production Departments
set @res = @res + '<' + @SIZE_HEADER + ' class="header">Production and R&D Departments</' + @SIZE_HEADER + '>' + CHAR(13)

if (@vacation_proddep_res is not null or @approve_vacation_proddep_res is not null or @approve_cancelation_proddep_res is not null)
	begin
		-- Absent today
		if (@vacation_proddep_res is not null)
		begin
			set @res =  @res + '<' + @SIZE_GROUP + ' class="group_header">Absent today</' + @SIZE_GROUP + '>' + CHAR(13)
			set @res = @res + CHAR(13) +
			  '<table class="GeneratedTable">'  + CHAR(13) 
			  + '<col style="width:33%"><col style="width:33%"><col style="width:33%">' + CHAR(13) 
			  + '<thead><tr>' + @headerrow + '<th>Absence type</th></tr></thead>' + CHAR(13)

			  + isnull(replace( replace( @vacation_proddep_res, '&lt;', '<' ), '&gt;', '>' ) +  + CHAR(13), '')			-- Absence

			  + '</table>' + CHAR(13)
		end
	
		-- Absence requests
		if(@approve_vacation_proddep_res is not null)
		begin
			set @res =  @res + '<' + @SIZE_GROUP + ' class="group_header">Absence requests</' + @SIZE_GROUP + '>' + CHAR(13)
			set @res = @res +
			  '<table class="GeneratedTable">'  + CHAR(13)
			  + '<col style="width:33%"><col style="width:33%"><col style="width:33%">' + CHAR(13) +
			  + '<thead><tr><th>Employee</th><th>Absence period</th><th>Link to document</th></tr></thead>'
			  + replace( replace( @approve_vacation_proddep_res, '&lt;', '<' ), '&gt;', '>' ) +  + CHAR(13)
			  + '<tr><td colspan="3" align="center"><a data-toggle="tooltip" title="Open list of all employees absence required in PDB on one page" href="a2l:\\Link=view.com_vacation_approval_req_prod_dep_mngmt">Open list in PDB</a></td></tr>'+
			  + '</table>'
		end

		-- Absence cancelation requests
		if(@approve_cancelation_proddep_res is not null)
		begin
			set @res =  @res + '<' + @SIZE_GROUP + ' class="group_header">Absence cancelation requests</' + @SIZE_GROUP + '>' + CHAR(13)
			set @res = @res +
			  '<table class="GeneratedTable">'  + CHAR(13)
			  + '<col style="width:33%"><col style="width:33%"><col style="width:33%">' + CHAR(13) +
			  + '<thead><tr><th>Employee</th><th>Absence period</th><th>Link to document</th></tr></thead>'
			  + replace( replace( @approve_cancelation_proddep_res, '&lt;', '<' ), '&gt;', '>' ) +  + CHAR(13)
			  + '</table>'
		end
	end
else
	set @res =  @res + @NORECORDS



-- Supporting Departments
set @res = @res + '<' + @SIZE_HEADER + ' class="header">Supporting Departments</' + @SIZE_HEADER + '>' + CHAR(13)

if (@vacation_supdep_res is not null  or @approve_vacation_supdep_res is not null or @approve_cancelation_supdep_res is not null)
	begin
		-- Absent today
		if(@vacation_supdep_res is not null)
		begin
			set @res =  @res + '<' + @SIZE_GROUP + ' class="group_header">Absent today</' + @SIZE_GROUP + '>' + CHAR(13)
			set @res = @res + CHAR(13) +
			  '<table class="GeneratedTable">'  + CHAR(13) 
			  + '<col style="width:25%"><col style="width:25%"><col style="width:25%"><col style="width:25%">' + CHAR(13) +
			  + '<thead><tr>' + @headerrow + '<th>Absence type</th></tr></thead>'
			  
			  + isnull(replace( replace( @vacation_supdep_res, '&lt;', '<' ), '&gt;', '>' ) +  + CHAR(13), '')			-- Absence
			  
			  + '</table>' + CHAR(13)
		end

		-- Absence requests
		if(@approve_vacation_supdep_res is not null)
		begin
			set @res =  @res + '<' + @SIZE_GROUP + ' class="group_header">Absence requests</' + @SIZE_GROUP + '>' + CHAR(13)
			set @res = @res +
			  '<table class="GeneratedTable">'  + CHAR(13)
			  + '<col style="width:33%"><col style="width:33%"><col style="width:33%">' + CHAR(13) +
			  + '<thead><tr><th>Employee</th><th>Absence period</th><th>Link to document</th></tr></thead>'
			  + replace( replace( @approve_vacation_supdep_res, '&lt;', '<' ), '&gt;', '>' ) +  + CHAR(13)
			  + '<tr><td colspan="3" align="center"><a data-toggle="tooltip" title="Open list of all employees absence required in PDB on one page" href="a2l:\\Link=view.com_vacation_approval_req_supp_dep_mngmt">Open list in PDB</a></td></tr>'+
			  + '</table>'
		end

		-- Absence cancelation requests
		if(@approve_cancelation_supdep_res is not null)
		begin
			set @res =  @res + '<' + @SIZE_GROUP + ' class="group_header">Absence cancelation requests</' + @SIZE_GROUP + '>' + CHAR(13)
			set @res = @res +
			  '<table class="GeneratedTable">'  + CHAR(13)
			  + '<col style="width:33%"><col style="width:33%"><col style="width:33%">' + CHAR(13) +
			  + '<thead><tr><th>Employee</th><th>Absence period</th><th>Link to document</th></tr></thead>'
			  + replace( replace( @approve_cancelation_supdep_res, '&lt;', '<' ), '&gt;', '>' ) +  + CHAR(13)
			  + '</table>'
		end
	end
else
	set @res =  @res + @NORECORDS


-- ###########  Стиль для отчета ########################################################################################

declare @appCol varchar(7)  = '#' + substring(CONVERT(varchar(max), CONVERT(VARBINARY(6), (select STATECOLOR from DEF_CLASS_STATES where CLASSOID = 1000184 and OID = 1000141)), 2),3,6)
declare @needCol varchar(7)  = '#' + substring(CONVERT(varchar(max), CONVERT(VARBINARY(6), (select STATECOLOR from DEF_CLASS_STATES where CLASSOID = 1000184 and OID = 1000140)), 2),3,6)
	

declare @STYLE varchar(max) = '<style>
.header {
  font: 1.5em Calibri;;
  font-weight: bolder;
  text-decoration: underline;
  text-underline-position: under;
}
.group_header {
  font: 1.2em Calibri;
  font-weight: bold;
}
table.GeneratedTable {
  width: 100%;
  font: 1em Calibri;
  background-color: #ffffff;
  border-collapse: collapse;
  border-width: 1px;
  border-color: #cdcdcd;
  border-style: solid;
  color: #000000;
}

table.GeneratedTable td {
  border-width: 1px;
  border-color: #cdcdcd;
  border-style: solid;
  padding: 3px;
} 
table.GeneratedTable th {
  border-width: 1px;
  border-color: #ffffff;
  border-style: solid;
  padding: 3px;
}

table.GeneratedTable thead {
  background-color: #cdcdcd;
}

p.footer {
	text-align: right;
	font: 1em Calibri;
	text-color: #FAFAFA
}

table.timeline {
            font: 1.1em Calibri;
            background-color: #ffffff;
            border-collapse: collapse;
            border-width: 1px;
            border-color: #cdcdcd;
            border-style: solid;
            color: #000000;
        }

            table.timeline td {
                font: 1em Courier New;
                border-width: 1px;
                border-color: #cdcdcd;
                border-style: solid;
                padding: 3px;
                
            }

            table.timeline th {
                font: 1.1em Calibri;
                border-width: 1px;
                border-color: #ffffff;
                border-style: solid;
                padding: 3px;
				background-color: #cdcdcd;
            }


        .approved {
            color: ' + @appCol + ';
            position: relative;
            display: inline-block;
			letter-spacing: 1.5px;
        }

        .needapprove {
            color: ' + @needCol + ';
            position: relative;
            display: inline-block;
			letter-spacing: 1.5px;
        }

		.sick {
	        color: indianred;
	        letter-spacing: 1.5px;
	    }

		 .workingday {
            letter-spacing: 1.5px;
			color: grey;
        }

		.pdblink {
            text-decoration:none;
        }

		

</style>'


-- ################### Непосредственно сам весь HTML ####################################################################

declare @HTML varchar(MAX) = 
		'<html style="font-family:verdanal">' + CHAR(13) +
		'<head>' + CHAR(13) + 
		@STYLE + CHAR(13) + 
		'</head>' + CHAR(13) +
		'<body>' + CHAR(13) +
		@res + CHAR(13) +
		'<br><br>' + CHAR(13) +

		'<' + @SIZE_HEADER + ' class="header">Departments timeline</' + @SIZE_HEADER + '>' + CHAR(13) +
		'<table class="timeline">'+
		--'<tr><td>Production and R&D Departments</td></tr>'+
		dbo.COM_DEP_HEADS_VACATIONS_HTML_TABLE(@nowDate, 8, 1) + CHAR(13) +
		--'<tr style="height:2px;"><td colspan="7"></td></tr>'+
		dbo.COM_DEP_HEADS_VACATIONS_HTML_TABLE(@nowDate, 8, 2) + CHAR(13) +
		'</table>' + CHAR(13) +
		'<br />' + CHAR(13) +
		'
		<div class="legend">
        <table>
            <tr>
                <td>
                    Approved Vacation:
                </td>
                <td class="legendcolumn">
                    <span class="approved">&#x2588;</span> - Full day, <span class="approved">&#x2580;</span> - Forenoon, <span class="approved">&#x2584;</span> - Afternoon, <span class="approved">&#x25CF;</span> - Short absence
                </td>
            </tr>

            <tr>
                <td>
                    Need to Approve Vacation:
                </td>
                <td class="legendcolumn">
                    <span class="needapprove">&#x2588;</span> - Full day, <span class="needapprove">&#x2580;</span> - Forenoon, <span class="needapprove">&#x2584;</span> - Afternoon, <span class="needapprove">&#x25CF;</span> - Short absence
                </td>
            </tr>
            <tr>
                <td>
                    Sick Leave:
                </td>
                <td class="legendcolumn">
                    <span class="sick">&#x2588;</span> - Full day, <span class="sick">&#x2580;</span> - Forenoon, <span class="sick">&#x2584;</span> - Afternoon
                </td>
            </tr>
        </table>
    </div>

		' + CHAR(13) +

		'<p class="footer">Created ' + [dbo].[COM_FORMAT_DATETIME](@nowDateTime,1) + '</p>' + CHAR(13) +
		'</body>' + CHAR(13) +
		'</html>'


--- ######### Отправка отчета ########################################################################

--select @HTML
--exec [dbo].[MSG_SEND_TOEMPLOYEE] 26052, 3228 , @SUBJ, @HTML
--return

exec MSG_SEND_TODELIVERYGROUP @aUSERID, @DELIVERYTYPE, @DELIVERYDEPID, @SUBJ, @HTML
print 'Reoprt SEND to Group.'

insert into MSG_LAST_DELIVERY_DATES (DELIVERYTYPE,DEPID,DD) values (@DELIVERYTYPE,@DELIVERYDEPID, @nowDate)
print 'Report date is inserted in [MSG_LAST_DELIVERY_DATES].'

set nocount off

END