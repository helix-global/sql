CREATE FUNCTION [dbo].[COM_DEP_VACATIONS_HTML_TABLE4](@startDate date, @WEEKS int, @PARENT_DEP_ID int)
returns varchar(max)
as
begin

/*TEST*/
--declare @PARENT_DEP_ID int = 203 --212 --84
--declare @WEEKS int = 8
--declare @startDate date = '20220131'
/*TEST*/

/* Issue 5139 - 2025-08-13 ME: Highlight the current date (new styles: .current_day_container, table.timeline th.current_date) {VMaslov} */
/*KB2715 Edit Fix 26.10.2021 Efimov*/
/* Если есть подчиненные отделы то табдлицы по ним тоже вставляются в тело письма*/

/*KB2984 - BOC - Corrections to email notifications about TimeLine 14.02.2022*/


declare @TABLE varchar(max) = ''


if not exists(select ID from  dbo.COM_GETCHILD_DEPARTMENTS2(@PARENT_DEP_ID,0))
--есть подчиненные отделы
begin
	--Получем html таблицу без CSS по ID департамента
	set @TABLE = dbo.COM_DEP_VACATIONS_HTML_TABLE_NOSTYLE4(@startDate, @WEEKS, @PARENT_DEP_ID)
end
else 
--нет подчиненных отделов
begin
	--Подчиненные департаменты
	declare @DEPARTMENTS table (DEPID int)
	insert into @DEPARTMENTS
	select ID from  dbo.COM_GETCHILD_DEPARTMENTS2(@PARENT_DEP_ID,1)

	--для всех подчиненных департаментов в цикле получаем таблицы
	declare @DEP_ID int
	DECLARE my_cur CURSOR FOR select DEPID from @DEPARTMENTS
	--открываем курсор
	OPEN my_cur
	--считываем данные первого отдела из списка рассылки
	FETCH NEXT FROM my_cur INTO @DEP_ID
	  --пока есть периоды в списке дней Vacations работника
	  WHILE @@FETCH_STATUS = 0
	  BEGIN
		  --Получем html таблицу без CSS по ID департамента
		  set @TABLE = @TABLE + ISNULL(dbo.COM_DEP_VACATIONS_HTML_TABLE_NOSTYLE4(@startDate, @WEEKS, @DEP_ID),'(Warning: department ID = ' + convert(varchar,@DEP_ID) + ' return NULL from dbo.COM_DEP_VACATIONS_HTML_TABLE_NOSTYLE)')
	      FETCH NEXT FROM my_cur INTO @DEP_ID
	  END
	CLOSE my_cur
	DEALLOCATE my_cur


end

--цвета для CSS
declare @appCol varchar(7)  = '#' + substring(CONVERT(varchar(max), CONVERT(VARBINARY(6), (select STATECOLOR from DEF_CLASS_STATES where CLASSOID = 1000184 and OID = 1000141)), 2),3,6)
declare @needCol varchar(7)  = '#' + substring(CONVERT(varchar(max), CONVERT(VARBINARY(6), (select STATECOLOR from DEF_CLASS_STATES where CLASSOID = 1000184 and OID = 1000140)), 2),3,6)

--сама страница с таблиц(ой/ами)
declare @HTML varchar(max) = 
	'
	<html>
	<head>
	    <style>
        td {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 10;
        }

        td.name {
            font-family: Calibri;
            font-size: 13;
        }

        .day_container {
            width: 16px;
            height: 30px;
            background-color: rgb(250, 250, 250);
            padding: 0px;
            vertical-align: top;
            border-collapse: collapse;
        }

        .current_day_container {
            width: 16px;
            height: 30px;
            padding: 0px;
            vertical-align: top;
            border-left: 2px solid;
            border-right: 2px solid;
            border-top: none;
            border-bottom: none;
            border-color: #0078D4;
            border-collapse: collapse;
        }

        table.week_container {
            width: 121px;
            height: 30px;
            background-color: transparent;
            padding: 0px;
            vertical-align: top;
            border: none;
            border-collapse: collapse;
        }

        .weekend_container {
            width: 16px;
            height: 30px;
            background-color: rgb(243, 243, 243);
            padding: 0px;
            vertical-align: top;
            border: 1px solid lightgrey;
        }

        .forenoon_approved {
            width: 16px;
            height: 15px;
            top: 15;
            text-align: center;
            background-color: #00C000;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            vertical-align: bottom;
            border: none;
            border-collapse: collapse;
        }

        .forenoon_approved tr td {
            align-items: center;
            background-color: #00C000;
            text-align: center;
            border: none;
            border-collapse: collapse;
        }

        .forenoon_approved a {
            text-decoration: none;
            color: white;
        }

        .afternoon_approved {
            padding: 0px;
            width: 16px;
            height: 30px;
            border: none;
            border-collapse: collapse;
        }

        .afternoon_approved tr td {
            border: 0px;
            width: 16px;
            padding: 0px;
            border: none;
            border-collapse: collapse;
        }

        .afternoon_approved_td {
            align-items: center;
            background-color: #00C000;
            text-align: center;
            border: none;
            border-collapse: collapse;
        }

        .afternoon_approved a {
            text-decoration: none;
            color: white;
        }

        .fullday_approved {
            width: 100%;
            text-align: center;
            vertical-align: middle;
            align-items: center;
            height: 30px;
            justify-content: center;
            background-color: #00C000;
            color: white;
            border: none;
            border-collapse: collapse;
        }

        .fullday_approved tr td {
            height: 30px;
            padding: 0px;
            vertical-align: middle;
            text-align: center;
            border: none;
            border-collapse: collapse;
        }

        .fullday_approved a {
            text-decoration: none;
            color: white;
        }

        .short_approved {
            text-align: center;
            vertical-align: middle;
            align-items: center;
            height: 30px;
            justify-content: center;
            background-color: transparent;
            color: #00C000;
            width: 100%;
            font-size: 20;
            border: none;
            border-collapse: collapse;
        }

        .short_approved tr td {
            width: 100%;
            padding: 0px;
        }

        .short_approved a {
            text-decoration: none;
            color: #00C000;
        }

        .forenoon_not_approved {
            width: 100%;
            height: 15px;
            top: 0;
            text-align: center;
            background-color: #FFC080;
            color: white;
            vertical-align: bottom;
            display: flex;
            justify-content: center;
            align-items: center;
            border: none;
            border-collapse: collapse;
            mso-border-alt: none;
        }

        .forenoon_not_approved tr td {
            border: 0px;
            width: 100%;
            padding: 0px;
            border: none;
            border-collapse: collapse;
        }

        .forenoon_not_approved a {
            text-decoration: none;
            color: white;
        }

        .afternoon_not_approved {
            padding: 0px;
            width: 100%;
            height: 30px;
            border: none;
            border-collapse: collapse;
        }

        .afternoon_not_approved_td {
            align-items: center;
            background-color: #FFC080;
            text-align: center;
            border: none;
            border-collapse: collapse;
        }

        .afternoon_not_approved tr td {
            width: 100%;
            padding: 0px;
            border: none;
            border-collapse: collapse;
            mso-border-alt: none;
        }

        .afternoon_not_approved a {
            text-decoration: none;
            color: white;
        }

        .fullday_not_approved {
            align-items: center;
            height: 30px;
            justify-content: center;
            background-color: #FFC080;
            color: white;
            width: 100%;
            border: none;
            border-collapse: collapse;
        }

        .fullday_not_approved tr td {
            width: 100%;
            padding: 0px;
            border: none;
            border-collapse: collapse;
        }

        .fullday_not_approved a {
            text-decoration: none;
            color: white;
        }

        .short_not_approved {
            text-align: center;
            vertical-align: middle;
            align-items: center;
            height: 30px;
            justify-content: center;
            background-color: transparent;
            border-color: transparent;
            color: #FFC080;
            width: 100%;
            font-size: 20;
            border: none;
            border-collapse: collapse;
        }

        .short_not_approved tr td {
            padding: 0px;
            border: none;
            border-collapse: collapse;
        }

        .short_not_approved a {
            text-decoration: none;
            color: #FFC080;
        }

        .seek_leave {
            text-align: center;
            vertical-align: middle;
            align-items: center;
            height: 30px;
            justify-content: center;
            background-color: indianred;
            color: white;
            width: 100%;
            border: none;
            border-collapse: collapse;
        }

        .seek_leave tr td {
            border: 0px;
            padding: 0px;
            border: none;
            border-collapse: collapse;
        }

        .seek_leave a {
            text-decoration: none;
            color: #F1B579;
            border: none;
        }

        table.timeline th {
            font: 1.1em Calibri;
            border-width: 1px;
            border-color: #ffffff;
            border-style: solid;
            background-color: #cdcdcd;
        }

        table.timeline th.current_date {
            border-width: 2px;
            border-color: #0078D4;
            background-color: #0078D4;
        }

        table,
        th,
        td {
            border: 1px solid lightgrey;
            white-space: nowrap;
        }

        .header {
            font: 1.5em Calibri;
            font-weight: bolder;
            text-decoration: underline;
            text-underline-position: under;
        }

        .approved {
            color: #00C000;
            display: inline-block;
            letter-spacing: 1.5px;
        }

        .needapprove {
            color: #FFC080;
            position: relative;
            display: inline-block;
            letter-spacing: 1.5px;
        }

        .seek {
            color: indianred;
            display: inline-block;
            letter-spacing: 1.5px;
            border-width: 0px;
        }
    </style>
	</head>
	<body>
	' 
	+ @TABLE
	+ CHAR(13)
	+ '<br/>'
	+ '
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
                <td> Sick Leave: </td>
                <td class="legendcolumn"> <span class="seek">&#x2588;</span> - Full day, <span
                        class="seek_leave">&#x2580;</span> - Forenoon, <span class="seek_leave">&#x2584;</span> - Afternoon </td>
            </tr>
			<tr><td>Letter "U":</td><td>Unpaid Leave</td></tr>    
            <tr><td>Letter "B":</td><td>Business Trip</td></tr>    
            <tr><td>Letter "T":</td><td>Training</td></tr>
            <tr><td>Letter "S":</td><td>Special Leave</td></tr>
            <tr><td>Letter "I":</td><td>Internal Appointment</td></tr>
            <tr><td>Letter "P":</td><td>Parental Leave</td></tr>
            <tr><td>Letter "C":</td><td>Child Care</td></tr>
        </table>
    </div>
	
	</body>
	</html>
	'
	

	return @HTML

end


--declare @H varchar(max) = [dbo].[COM_DEP_VACATIONS_HTML_TABLE2](GetDate(), 8, 82)
--exec [dbo].[MSG_SEND_TOEMPLOYEE] 26052, 3228 , 'test', @HTML
--exec MSG_SEND_TODELIVERYGROUP 26052, 9999, 278, 'test', @H

--select @HTML