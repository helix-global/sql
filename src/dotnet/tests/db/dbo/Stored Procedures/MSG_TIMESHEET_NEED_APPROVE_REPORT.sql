CREATE PROCEDURE [dbo].[MSG_TIMESHEET_NEED_APPROVE_REPORT] @aUserID int
AS
BEGIN

/* KB2968 - FOC_G - New notification list */

/* FOR TEST */
--DECLARE @aUSERID int = 26052 --
/* FOR TEST */

SET NOCOUNT ON

DECLARE @nowDateTime datetime = getdate();
DECLARE @nowDATE date = @nowDateTime
DECLARE @nowTime time = @nowDateTime
--------------------------------------------
DECLARE @SearchYear int = year(DATEADD(week, -1, @nowDATE)) -- previous week year
DECLARE @SearchWeekNumber int =   DATEPART(week, @nowDATE)-2 --previous week number (start with 0 thats why -2)
DECLARE @SearchWeek varchar(2)  =  (select right ('00'+ltrim(str( @SearchWeekNumber)),2 ))  --week number with leadinbg 0 like 04,06
DECLARE @WEEKN varchar(6) = convert(varchar(4), @SearchYear) + @SearchWeek -- variable for search like 202204 (where 2022 is year and 04 is week)
--------------------------------------------
DECLARE @tablerows varchar(max) = '';	-- for table rows
DECLARE @html varchar(max) = '';		-- for html email body
--------------------------------------------
DECLARE @SUBJ varchar(250) = 'Notifications about not approved TimeSheets' -- subj for email
DECLARE @DELIVERYTYPE int = 1995 --Notifications about not approved TimeSheets
DECLARE @DELIVERYDEPID int  -- for cursor
--------------------------------------------
DECLARE @REPORTWEEKDAY int = 1			--понедельник
DECLARE @REPORTTIME time = '17:00'		-- после 17:00

 

 -- ############## ПРОВЕРКА НА ПОНЕДЕЛЬНИК #########################################
SET DATEFIRST 1 ;
if (DATEPART(WEEKDAY, GETDATE()) <> @REPORTWEEKDAY)
begin
   print 'exit (everybody wait report at monday)'
   set nocount off
   return
end

-- ################# ПРОВЕРКА НА УЖЕ ОТПРАВЛЕННЫЙ ОТЧЕТ ###########################################
 if exists (select G.DD from MSG_LAST_DELIVERY_DATES G where G.DELIVERYTYPE = @DELIVERYTYPE and G.DEPID = -1 and G.DD = cast(@nowDATE as date))
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




-- #################### ОТПРАВКА ОТЧЕТА ###################################

DECLARE @res table (TS_ID int, EMPL_NAME varchar(250), CONTR_AGENCY varchar(250), DEPID int)
insert into @res
select 
	TS.ID TS_ID,
	E.[NAME] EMPL_NAME,
	ZA.NAME CONTR_AGENCY,
	E.DEPID
from 
	dbo.COM_ZEITARBEITREPORT TS with (nolock)
	join dbo.COM_EMPLOYEE E with (nolock) on E.ID = TS.EMPLID
	join dbo.COM_ZEITAFIRMA ZA with (nolock) on ZA.ID = E.ZAFID
where 
	TS.WEEKN = @WEEKN	--предыдущая неделя
	and 
	E.ISTEMP = 1 -- contractor employee
	and
	TS.S_S = 2130017 /*Applyed but not Approved*/




/* КУРСОР ДЛЯ ВСЕХ ОТДЕЛОВ В ВЫБРАННЫХ TIMESHEET*/
DECLARE my_cur CURSOR FOR 
	select DISTINCT DEPID from 	@res 
	--открываем курсор
	OPEN my_cur
	--считываем данные первого отдела из списка рассылки
	FETCH NEXT FROM my_cur INTO @DELIVERYDEPID
	  --прока есть периоды в списке дней Vacations работника
	  WHILE @@FETCH_STATUS = 0
	  BEGIN


		 /* Create html body for email */
		-- create table rows for every DEPID
		 set @tablerows	= ''
		 select
			@tablerows	=
			@tablerows +
			'		<tr> 
					    <td>' + R.EMPL_NAME + '</td>
					    <td>' + R.CONTR_AGENCY + '</td>
						<td><a href ="' + 'a2l:\\Link=doc.com_zeitarbeitreport.' + CONVERT(varchar, R.TS_ID) + '">open in PDB...</a></td>
					</tr>' + CHAR(13)
			from @res R 
			where R.DEPID = @DELIVERYDEPID 
			order by R.EMPL_NAME
		
		 -- join table rows wuth all other html
		 set @html  = '
<html>
<head>
	<style>
		body {
			font: 1em Calibri;
		}
		table {
            font: 1em Calibri;
            background-color: #ffffff;
            border-collapse: collapse;
            border-width: 1px;
            border-color: #cdcdcd;
            border-style: solid;
            color: #000000;
        }
		table td {
            font: 1em Calibri;
            border-width: 1px;
            border-color: #cdcdcd;
            border-style: solid;
            padding: 3px 15px 3px 15px;
        }
		
        table th {
            font: 1.1em Calibri;
			font-weight: bold;
            border-width: 1px;
            border-color: #ffffff;
            border-style: solid;
            padding: 3px 15px 3px 15px;
			background-color: #cdcdcd;
        }
	</style>
</head>	
<body>
Dear All,</br>
</br>
At the moment "Timesheet" documents by current week are applied but not approved by the following employee:</br>
</br>
<table>
	<tr>
		<th>Employee name</th>
		<th>Contract agency</th>
		<th>Link to Time Sheet</th>
	</tr>
'
+ @tablerows+
'
</table></br>
Checking time: ' + dbo.COM_FORMAT_DATETIME(GETDATE(),1) + '</br>
</br>
Please do not reply.</br>
Production Database</br>
</body>
</html>
'
		 /* Create html body for email */

		  -- отправка в нужную группу в нужный департамент (если есть)
		  print '###################'
		  
		  exec MSG_SEND_TODELIVERYGROUP @aUSERID, @DELIVERYTYPE, @DELIVERYDEPID, @SUBJ, @html

		  print 'Report SEND to DepID ' + convert(varchar,@DELIVERYDEPID)

	      FETCH NEXT FROM my_cur INTO @DELIVERYDEPID
	  END
	 CLOSE my_cur
DEALLOCATE my_cur


print '###################'
insert into MSG_LAST_DELIVERY_DATES (DELIVERYTYPE,DEPID,DD) values (@DELIVERYTYPE,-1, @nowDate)
print 'Report date is inserted in [MSG_LAST_DELIVERY_DATES].'
print 'Report SEND to Group.'

SET NOCOUNT OFF

end