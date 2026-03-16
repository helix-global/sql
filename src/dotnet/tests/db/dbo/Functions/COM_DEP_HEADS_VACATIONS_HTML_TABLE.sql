/****************************** ТАБЛИЦА *************************************/

/*
24.04.2024	KB4748	efimov
*/


CREATE FUNCTION [dbo].[COM_DEP_HEADS_VACATIONS_HTML_TABLE](@startDate date, @weeks int, @PRODDEP int)
returns nvarchar(max)
as
begin



	/* TEST DATA */
	--declare @weeks int = 8
	--declare @PRODDEP int = 1 -- 1 prod, 2 supp dep
	--declare @startDate date = '20230223'
	/* TEST DATA */
	
	
	declare @fullday1 varchar(250)   = '&#x2588;'--'&#x2588;' --'█' <span class="tooltip">&#x2588;<span class="tooltiptext">Full day</span></span>
	declare @forenoon2 varchar(250)  = '&#x2580;' --'&#x2580;' --'▄'
	declare @afternoon3 varchar(250) = '&#x2584;' --'&#x2584;' --'▀'
	declare @shortAbsence30 varchar(250) = '&#x25CF;' --'&#x25CF;' --'●'
	declare @foreground varchar(10) = '·' -- '&#x2012;' --'-' -- 
	declare @fullday4	    varchar(250) = '&#x2588;' --'█'
	
	declare @appCol varchar(7)  = '#' + substring(CONVERT(varchar(max), CONVERT(VARBINARY(6), (select STATECOLOR from DEF_CLASS_STATES where CLASSOID = 1000184 and OID = 1000141)), 2),3,6)
	declare @needCol varchar(7)  = '#' + substring(CONVERT(varchar(max), CONVERT(VARBINARY(6), (select STATECOLOR from DEF_CLASS_STATES where CLASSOID = 1000184 and OID = 1000140)), 2),3,6)
	
	
	--Дата начала стартовой недели
	declare @nowDATE date =  (select top 1 DDATE from COM_WEEK(@startDate) order by DDATE) --cast(@nowDateTime as date) 
	
	
	--таблица для только нужных нам зхаписей по дкпартаментам и датам
	declare @VACATION table (EMPLID int, EMPLNAME varchar(250), DBEG date, DEND date, VACATIONTYPE int, PERIODTYPE int, S_S int, ID int)
	--заполнение этой таблицы
	insert into @VACATION
	select DISTINCT V.EMPLID, V.EMPLNAME, V.DBEG, isnull(V.DEND,V.DBEG), V.VACATIONTYPE, V.PERIODTYPE, V.S_S , V.ID
	from  [dbo].[COM_DEP_HEADS_VACATIONS]() V
	where 
		(
		(V.DBEG >= @nowDATE and V.DBEG < DATEADD(week,@weeks,@nowDATE)) 
		or 
		(V.DBEG <= @nowDATE and isnull(V.DEND,V.DBEG)  >= @nowDATE)
		)
	and V.S_S in (1000140, 1000141,2130051)--123661
	and V.VACATIONTYPE not in (200)
	and V.PRODDEP = @PRODDEP
	order by V.EMPLNAME
	

	/*  REMOVE DUPLICATES */
	;WITH cte AS (
    SELECT  
		ID,EMPLID, EMPLNAME, DBEG, DEND, VACATIONTYPE, PERIODTYPE, S_S
        , 
        ROW_NUMBER() OVER (
            PARTITION BY 
                EMPLID, EMPLNAME, DBEG, DEND, VACATIONTYPE, PERIODTYPE, S_S
            ORDER BY 
                ID
        ) row_num
     FROM 
        @VACATION
	 )
	 DELETE FROM cte
	 WHERE row_num > 1;



	 --#####################################################################
	



	/* KB 3290 Если человек вазял 2 отпуска в 1 день - forenoon + afternoon, то  afternoon "переделываем" в полный 1 день для правильного отображения*/
	-- afternoon у которого есть forenoon - переименовывавем/переделываем в fullday
	/* KB3735 Дополнение.... Если у человека есть 2 отсутствия в 1 день с типом периодов forenoon + afternoon то отображаем как 1 день (ероме короткого отсутсвия и внутренней встречи) */
	update  
		@VACATION
	set 
		PERIODTYPE = 4  
	from 
		@VACATION V2
		join (
			select * from @VACATION where VACATIONTYPE not in (30 /*short absence*/, 80 /*Internal Appointment*/) and PERIODTYPE = 2  --KB3735
		) V1 on V2.DBEG = V1.DBEG and V2.EMPLID=V1.EMPLID
	where 
		V2.VACATIONTYPE not in (30 /*short absence*/, 80 /*Internal Appointment*/) and  V2.PERIODTYPE = 3  --KB3735 

	-- у переделанного fullday если есть "оставшийся" forenoon (afternoon мы до этого переименовали в fullday), то удаляем
	delete
		@VACATION
	from 
		@VACATION V1
		join (
			select * from @VACATION where  VACATIONTYPE not in (30 /*short absence*/, 80 /*Internal Appointment*/) and  PERIODTYPE = 1 --KB3735
		) V2 on V1.DBEG = V2.DBEG and V1.EMPLID=V2.EMPLID
	where 
		V1.VACATIONTYPE not in (30 /*short absence*/, 80 /*Internal Appointment*/) and  V1.PERIODTYPE = 2 --KB3735
	/*******************************************************************************************/



	
	--таблица где хранить результативную информацию по имя работника и его timeline
	declare @TimeLines table (EmplName varchar(250), EmplTimeLine varchar(MAX))   
	
	declare @aEmplID int   -- переменная для хранения EMPLID при перечислении всех из списка Vacations
	declare @aEmplName varchar(250)   -- переменная для хранения EMPLNAME (имени) при перечислении всех из списка Vacations
	
	--cursor по всем уникальным работникам в Vacations
	DECLARE my_cur_empl_id CURSOR FOR select distinct EMPLID, EMPLNAME from @VACATION
	OPEN my_cur_empl_id
	FETCH NEXT FROM my_cur_empl_id INTO @aEmplID, @aEmplName
	WHILE @@FETCH_STATUS = 0
	
	--на каждого EMPLOYEE в списке Prod Departments   
	BEGIN
	
		declare @bDate date -- = '20210827'
		declare @eDate date --= '20210831'
		declare @vacationType int -- = 30
		declare @periodType int   --= null
		declare @S_S int 
		declare @YY int
		declare @ID int
	
		--все даты Vactions данного работника списком по дням
		declare @allUerDates table (EMPLID int, DDATE date, WW int, VacationType int, PeriodType int, DAYN int, S_S int, YY int, ID int)
	
		--константа сдвига недели чтобы текущая была 1 (первой) след 2 (второй) и т.д.
		declare @weekShift int = (select top 1 WW from COM_WEEK_PERIOD(@nowDATE,@nowDate)) -1
		--последняя неделя текущего дгода ?!
		--declare @lastweek int = (select TOP 1 WW from COM_WEEK_PERIOD4(convert(varchar,year(GETDATE())) + convert(varchar,'1231'),convert(varchar,year(GETDATE())) + convert(varchar,'1231')))
		--declare @lastweek int = (select TOP 1 WW from COM_WEEK_PERIOD4((select DBEG from dbo.COM_WEEK_FIRST_LAST_DAYS(year(GETDATE()),52)),(select DBEG from dbo.COM_WEEK_FIRST_LAST_DAYS(year(GETDATE()),52))))
		declare @lastweek int = 52;
	
	
		--####################### Заполняем таблицу всеми днями из всех периодов пользователя
		--объявляем курсор
		DECLARE my_cur CURSOR FOR 
		 select V.DBEG, V.DEND, V.VACATIONTYPE, V.PERIODTYPE,V.S_S ,V.ID
		 from  @VACATION V
		 where V.EMPLID = @aEmplID
		--открываем курсор
		OPEN my_cur
		--считываем данные первого периода в списке по сотруднику
		FETCH NEXT FROM my_cur INTO @bDate, @eDate, @vacationType, @periodType, @S_S, @ID
	    --прока есть периоды в списке дней Vacations работника
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
	        --вставляем в тбалицу все дни между DBEG и DEND
			--IF ((@vacationType = 30 and NOT EXISTS(SELECT * FROM @allUerDates where DDATE = @bDate)) or @vacationType <> 30)
			
	
			if (EXISTS(SELECT DDATE FROM @allUerDates where DDATE = @bDate))
			begin
				DELete from @allUerDates where DDATE = @bDate
			end
	
			insert into @allUerDates 
			select 
				@aEmplID,
				DP.DDATE,

				--case when year(DP.DDATE) > year(GETDATE()) then (select TOP 1 WW from COM_WEEK_PERIOD4(DP.DDATE, DP.DDATE)) + @lastweek else 
				--(select TOP 1 WW from COM_WEEK_PERIOD4(DP.DDATE, DP.DDATE)) - @weekShift end as WW,
				case 
					when 
						year(DP.DDATE) > year(GETDATE()) 
					then 
						(select TOP 1 WW from COM_WEEK_PERIOD4(DP.DDATE, DP.DDATE)) + @lastweek - @weekShift
					else 
						(select TOP 1 WW from COM_WEEK_PERIOD4(DP.DDATE, DP.DDATE)) - @weekShift 
				end as WW,
				
				--(select TOP 1 WW from COM_WEEK_PERIOD4(DP.DDATE, DP.DDATE)) - @weekShift as WW,
				@vacationType as VacationType, 
				@periodType as PeriodType, 
				NULL,
				@S_S as S_S, 
				NULL,
				@ID as ID
				from COM_DAY_PERIOD(@bDate, @eDate) DP 
			
	        --считываем следующую данные  периода в списке по сотруднику
	        FETCH NEXT FROM my_cur INTO @bDate, @eDate, @vacationType, @periodType, @S_S, @ID
	   END
	   CLOSE my_cur
	   DEALLOCATE my_cur
	

	  
	  
	   
	
	   ---############# проставляем дни недели (номера 1234567) в полученный список и года
	   update @allUerDates
	   set DAYN = 
	   (select DAYN from COM_WEEK(AUD.DDATE) CW where CW.DDATE = AUD.DDATE)
	   , YY = YEAR(AUD.DDATE)
	   from 
		@allUerDates AUD
	
	
		--Объявляем переменную для текстовой строки timeline (отрисовка дней недели с absence)
		DECLARE @weekTimeLine VARCHAR(max);
		DECLARE @tableHead varchar(max) = '<tr><th>' + case 
															when @PRODDEP=1 then '<a href="a2l:\\Link=view.com_vacation_timeline_hd' + convert(varchar,@PRODDEP) + '">Production and R&D Departments</az>' 
															when @PRODDEP=2 then '<a href="a2l:\\Link=view.com_vacation_timeline_hd' + convert(varchar,@PRODDEP) + '">Supporting Departments</a>' 
															else '<a href="a2l:\\Link=view.com_vacation_timeline_hd' + convert(varchar,@PRODDEP) + '">All Departments</a>' 
														end  + '</th><th>CW' + convert(varchar,1 + (case when @weekShift < @lastweek /*52*/ then @weekshift else @weekshift-@lastweek /*52*/ end) )  + '</th>'
	
		--для всех искомых недель с сегодняшней (1) до какой нужно (кол-во в настройках в начале) от сегодняшней
		DECLARE @week INT = 1;
		WHILE @week <= @weeks
		BEGIN
		   
			--Первая дата из недели которую проверяем
			declare @checkDate date = (select top 1 DDATE from @allUerDates where WW = @week)
	
			SELECT 
				@weekTimeLine = ISNULL(@weekTimeLine ,'') + 
				
					case when aDAYS.DAYN = 0	--нет absence 
						then 
							'<span class="workingday">' + @foreground + '</span>' 
						else 
							case 
								when aDAYS.VacationType = 20 -- Sick Leave
									then 
										case
											when aDAYS.PeriodType = 1 then '<span class="sick">' + @fullday1 + '</span>'
											when aDAYS.PeriodType = 2 then '<span class="sick">' + @forenoon2 + '</span>'
											when aDAYS.PeriodType = 3 then '<span class="sick">' + @afternoon3 + '</span>'
											else '<span class="sick">' + @fullday1 + '</span>'
										end
								when aDAYS.VacationType = 30 -- короткое отсутсвие
								then 
									case when aDAYS.S_S = 1000140 
										then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @shortAbsence30 + '</span></a>' 
										else '<span class="approved">' + @shortAbsence30 + '</span>' 
									end
								else 
									case 
										when aDAYS.PeriodType = 1 
											then 
												case when aDAYS.S_S = 1000140 
													then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @fullday1 + '</span></a>' 
													else '<span class="approved">' + @fullday1 + '</span>' 
												end
										when aDAYS.PeriodType = 2 
											then 
												case when aDAYS.S_S = 1000140 
													then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @forenoon2 + '</span></a>' 
													else '<span class="approved">' + @forenoon2 + '</span>' 
												end
										when aDAYS.PeriodType = 3 
											then 
												case when aDAYS.S_S = 1000140
													then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @afternoon3 + '</span></a>' 
													else '<span class="approved">' + @afternoon3 + '</span>' 
												end
										when aDAYS.PeriodType = 4 -- полный день "переделанный" из forenoon+afternoon
											then 
												case 
													when aDAYS.S_S = 1000140 
													then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @fullday4 + '</span></a>' 
													else '<span class="approved">' + @fullday4 + '</span>' 
												end
										else 
											case when aDAYS.S_S = 1000140
												then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @fullday1 + '</span></a>' 
												else '<span class="approved">' + @fullday1 + '</span>' 
											end 
									end
							end
					end
					
		
			from(
					-- соотносим даты absence за неделю ко всем дням недели
					select ISNULL(DATES.DAYN, 0) DAYN,
						DATES.VacationType, 
						DATES.PeriodType, 
						DATES.S_S,
						DATES.DDATE,
						DATES.ID
						
					from COM_WEEK(@checkDate) ALLWEEK
					left join (select VacationType, PeriodType, S_S, DDATE, DAYN, ID from @allUerDates where WW = @week) as DATES on DATES.DDATE = ALLWEEK.DDATE
			) aDAYS


			
			set @weekTimeLine = @weekTimeLine +  case when @week = @weeks then '' else  '|' end
			
			set @tableHead = @tableHead + 
			case when @week > 1 then 
				'<th>' + 'CW'+ CONVERT(varchar, 
					--case when @week < @lastweek then @week + @weekShift else @week-@lastweek end
					case when (@week + @weekShift) > @lastweek /*52*/
						then 
							 (@week + @weekShift) - @lastweek /*52*/
						else 
							@week + @weekShift 
					end
				) + '</th>' + case when @week = @weeks then '</tr>'+ CHAR(13)  else  '' end
				else ''
			end
			
	
		 SET @week = @week + 1;
		END;
		--добавляем полдьзователя с timeline
		insert into @TimeLines
		select @aEmplName, @weekTimeLine
	
		set @weekTimeLine = null
	
		delete from  @allUerDates;
		
	
	
	-- перечисление aEmplID по PROD departmets	    
	--считываем следующую строку курсора
	FETCH NEXT FROM my_cur_empl_id INTO @aEmplID,@aEmplName
	END
	--закрываем курсор
	CLOSE my_cur_empl_id
	DEALLOCATE my_cur_empl_id
	
	
	declare @table varchar(max);
	select 
		@table = ISNULL(@table,'') + 
		'<tr>' + 
		'<td nowrap style="font-family: Calibri;">' + T.EmplName + '</td>' +	'<td nowrap>' + REPLACE(T.EmplTimeLine,'|','</td><td nowrap>') + '</td>'+
		'</tr>' + CHAR(13)
	from 
		@TimeLines T
	
	order by 
		EmplName
	

	
	--set @table = '<table class="timeline">' + 
	--@tableHead +  @table 
	--+'</table>'
	

	declare @SUBJ varchar(max) = 'Test TABLE for report'
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
	                letter-spacing: 1px;
	            }
	
	            table.timeline th {
	                font: 1.1em Calibri;
	                border-width: 1px;
	                border-color: #ffffff;
	                border-style: solid;
	                padding: 3px;
	            }
	
	            table.timeline thead {
	                background-color: #cdcdcd;
	            }
	
			.sick {
			        color: indianred;
			        position: relative;
			        display: inline-block;
			        letter-spacing: 1.5px;
			    }

			.approved {
				color: '+ @appCol + ';
	        }
			.needapprove {
				color: '+ @needCol + ';
	        }
	    </style>
	</head>
	</head>
	<body>
	' 
	+ @table
	+ '
	</body>
	</html>
	'
	
	--declare @H varchar(max) = @tableHead +  @table
	--exec [dbo].[MSG_SEND_TOEMPLOYEE] 26052, 3228 , @SUBJ,  @HTML
	
return @tableHead +  @table
	
end