

CREATE FUNCTION [dbo].[COM_DEP_VACATIONS_HTML_TABLE3](@startDate date, @WEEKS int, @PARENT_DEP_ID int)
returns varchar(max)
as
begin

/*TEST*/
--declare @PARENT_DEP_ID int = 203 --212 --84
--declare @WEEKS int = 8
--declare @startDate date = '20220131'
/*TEST*/

/*KB2715 Edit Fix 26.10.2021 Efimov*/
/* Если есть подчиненные отделы то табдлицы по ним тоже вставляются в тело письма*/

/*KB2984 - BOC - Corrections to email notifications about TimeLine 14.02.2022*/


declare @TABLE varchar(max) = ''


if not exists(select ID from  dbo.COM_GETCHILD_DEPARTMENTS2(@PARENT_DEP_ID,0))
--есть подчиненные отделы
begin
	--Получем html таблицу без CSS по ID департамента
	set @TABLE = dbo.COM_DEP_VACATIONS_HTML_TABLE_NOSTYLE3(@startDate, @WEEKS, @PARENT_DEP_ID)
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
		  set @TABLE = @TABLE + ISNULL(dbo.COM_DEP_VACATIONS_HTML_TABLE_NOSTYLE(@startDate, @WEEKS, @DEP_ID),'(Warning: department ID = ' + convert(varchar,@DEP_ID) + ' return NULL from dbo.COM_DEP_VACATIONS_HTML_TABLE_NOSTYLE)')
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
            width: 13px;
            height: 26px;
            position: relative;
            background-color: rgb(250, 250, 250);

        }

        .weekend_container {
            width: 13px;
            height: 26px;
            position: relative;
            background-color: rgb(243, 243, 243);
        }



        .forenoon_approved {
            width: 100%;
            height: 50%;
            top: 0;
            text-align: center;
            background-color: '+  @appCol + ';
            color: white;
            vertical-align: bottom;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .forenoon_approved a {
            text-decoration: none;
            color:white;
        }



        .afternoon_approved {
            width: 100%;
            height: 50%;
            top: 50%;
            position: absolute;
            text-align: center;
            background-color: '+  @appCol + ';
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .afternoon_approved a {
            text-decoration: none;
            color:white;
        }

        .fullday_approved {
            display: flex;
            align-items: center;
            height: 100%;
            justify-content: center;
            background-color: '+  @appCol + ';
            color: white;
            width: 100%;
        }

        .fullday_approved a {
            text-decoration: none;
            color:white;
        }
        



        .short_approved {
            display: flex;
            align-items: center;
            height: 100%;
            justify-content: center;
            background-color: transparent;
            color: ' + @appCol + ';
            width: 100%;
            font-size: 20;
        }

        .short_approved a {
            text-decoration: none;
            color: '+  @appCol + ';
        }

        .forenoon_not_approved {
            width: 100%;
            height: 50%;
            top: 0;
            text-align: center;
            background-color: '+ @needCol + ';
            color: white;
            vertical-align: bottom;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .forenoon_not_approved a {
            text-decoration: none;
            color:white;
        }



        .afternoon_not_approved {
            width: 100%;
            height: 50%;
            top: 50%;
            position: absolute;
            text-align: center;
            background-color: '+ @needCol + ';
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .afternoon_not_approved a {
            text-decoration: none;
            color:white;
        }


        .fullday_not_approved {
            display: flex;
            align-items: center;
            height: 100%;
            justify-content: center;
            background-color: '+ @needCol + ';
            color: white;
            width: 100%;
        }

        .fullday_not_approved a {
            text-decoration: none;
            color:white;
        }


        .short_not_approved {
            display: flex;
            align-items: center;
            height: 100%;
            justify-content: center;
            background-color: transparent;
            color: '+ @needCol + ';
            width: 100%;
            font-size: 20;
        }

        .short_not_approved a {
            text-decoration: none;
            color: '+ @needCol + ';
        }

        .seek_leave {
            display: flex;
            align-items: center;
            height: 100%;
            justify-content: center;
            background-color: indianred;
            color: white;
            width: 100%;
            font-size: 20;
            font-weight: bolder;
        }

        .seek_leave a {
            text-decoration: none;
            color: #F1B579;
        }




        table.timeline th {
            font: 1.1em Calibri;
            border-width: 1px;
            border-color: #ffffff;
            border-style: solid;

            background-color: #cdcdcd;
        }

        table,
        th,
        td {
            border: 1px solid lightgrey;
            border-collapse: collapse;
			white-space: nowrap;
        }

        .header {
            font: 1.5em Calibri;
            ;
            font-weight: bolder;
            text-decoration: underline;
            text-underline-position: under;
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
            position: relative;
            display: inline-block;
            letter-spacing: 1.5px;
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
                <td>
                    Sick Leave:
                </td>
                <td class="legendcolumn">
                    <span class="sick">&#x2588;</span> - Full day, <span class="sick">&#x2580;</span> - Forenoon, <span class="sick">&#x2584;</span> - Afternoon
                </td>
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