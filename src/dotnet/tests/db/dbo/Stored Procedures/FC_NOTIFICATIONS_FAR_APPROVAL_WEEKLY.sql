


CREATE PROCEDURE [dbo].[FC_NOTIFICATIONS_FAR_APPROVAL_WEEKLY] @aUserID int
AS
BEGIN


--declare @aUSERID int = (select ID from DEF_USERS where LOGINNAME2 = CURRENT_USER)


/* KB4047 */

SET NOCOUNT ON

DECLARE @nowDateTime datetime = getdate();
DECLARE @nowDATE date = @nowDateTime
DECLARE @nowTime time = @nowDateTime
--------------------------------------------
DECLARE @tablerows varchar(max) = '';	-- for table rows
DECLARE @html varchar(max) = '';		-- for html email body
--------------------------------------------
DECLARE @STATE int = 1000103 /* Analized */
DECLARE @SUBJ varchar(250) = 'Notification about FAR approval - Weekly' -- subj for email
DECLARE @DELIVERYTYPE int = 1450 --Notification about FAR approval - Weekly (Friday)
DECLARE @DELIVERYDEPID int  -- for cursor
DECLARE @res table( ID varchar(20), NAME varchar(300), SN varchar(50),FAILUREDATE varchar(50), SERVICENUMBER varchar(50), SORTDATE DateTime ) -- таблица для отчета по департаменту
--------------------------------------------
DECLARE @REPORTWEEKDAY int = 5			-- пятница
DECLARE @REPORTTIME time = '8:00'		-- после 8:00



-- ############## ПРОВЕРКА НА ПЯТНИЦУ #########################################
SET DATEFIRST 1 ;
if (DATEPART(WEEKDAY, GETDATE()) <> @REPORTWEEKDAY)
begin
   print 'exit (everybody wait report at пятниццо)'
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


-- таблица отчета



/* КУРСОР ДЛЯ ВСЕХ ОТДЕЛОВ В ВЫБРАННЫХ TIMESHEET*/
DECLARE my_cur CURSOR FOR 
	select DISTINCT DEPID from MSG_DELIVERYLIST where DELIVERYTYPE = @DELIVERYTYPE
	--открываем курсор
	OPEN my_cur
	--считываем данные первого отдела из списка рассылки
	FETCH NEXT FROM my_cur INTO @DELIVERYDEPID
	  --прока есть периоды в списке дней Vacations работника
	  WHILE @@FETCH_STATUS = 0
	  BEGIN

		  -- отправка в нужную группу в нужный департамент (если есть)
		  print '###################'
		  
		  -- Выборка для отчета
		  delete from @res -- чистим
		  
		  insert into @res --заполняем по департаменту
		  select TOP 1000 
			FC.ID, M.NAME, FC.SN, dbo.COM_FORMAT_DATETIME(FC.FAILUREDATE,1) FAILUREDATE, isnull(FC.RMA,'') SERVICENUMBER, FAILUREDATE
		  from		
			FC_REPORT as FC with (nolock) 
		  left join 
			PR_MODELS M with (nolock) on M.ID = FC.MODELID
	      where		
			FC.S_S = @STATE and FC.FROMDEPID = @DELIVERYDEPID --and year(FC.S_CDT) = 2023
		  order by FC.FAILUREDATE DESC

		  --html строки для таблицы из отчета
		  set @tablerows =''
		  select @tablerows = @tablerows + 
			'<tr>' + CHAR(13) +
			'	<td>' +  '<a href = "a2l:\\Link=doc.fc_report.'+ ID + '">'+ ID +'<a>' + '</dt>' + CHAR(13) +
			'	<td>' + NAME + '</dt>' + CHAR(13) +
			'	<td>' + SN + '</dt>' + CHAR(13) +
			'	<td>' + FAILUREDATE + '</dt>' + CHAR(13) +
			'	<td>' + SERVICENUMBER + '</dt>' + CHAR(13) +
			'</tr>' + CHAR(13)
		  from @res
		  order by SORTDATE DESC
		  

		  -- create body for email
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
There is last <b>' + convert(varchar(100),(select Count(*) from @res)) + '</b> failure reports without approval</br>
</br>
<table>
	<tr>
		<th>ID (link)</th>
		<th>Model</th>
		<th>SN</th>
		<th>Date of receipt</th>
		<th>Service number</th>
	</tr>
'
+ @tablerows +
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


		  exec MSG_SEND_TODELIVERYGROUP @aUSERID, @DELIVERYTYPE, @DELIVERYDEPID, @SUBJ, @html
		  
	
	      FETCH NEXT FROM my_cur INTO @DELIVERYDEPID
	  END
	 CLOSE my_cur
DEALLOCATE my_cur


print '###################'
insert into MSG_LAST_DELIVERY_DATES (DELIVERYTYPE,DEPID,DD) values (@DELIVERYTYPE,-1, @nowDate)
print 'Report ' + convert(varchar(10),@DELIVERYTYPE) + ' date is inserted in [MSG_LAST_DELIVERY_DATES].'
print 'Report SEND to Group.'

SET NOCOUNT OFF

END