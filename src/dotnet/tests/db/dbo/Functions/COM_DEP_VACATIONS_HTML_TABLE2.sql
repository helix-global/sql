

CREATE FUNCTION [dbo].[COM_DEP_VACATIONS_HTML_TABLE2](@startDate date, @WEEKS int, @PARENT_DEP_ID int)
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
	set @TABLE = dbo.COM_DEP_VACATIONS_HTML_TABLE_NOSTYLE(@startDate, @WEEKS, @PARENT_DEP_ID)
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
            position: relative;
            display: inline-block;
            letter-spacing: 1.5px;
        }

		 .workingday {
            letter-spacing: 1.5px;
			color: grey;
        }

		.pdblink {
            text-decoration:none;
        }
		.header {
		  font: 1.5em Calibri;;
		  font-weight: bolder;
		  text-decoration: underline;
		  text-underline-position: under;
		}
		.legend {
            color: grey;
            font: 1.1em Calibri;
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