/****************************** ТАБЛИЦА *************************************/

-- KB4604 - 2024-02-14 LDM: Фиксация данных для отображения по сотруднику у которого перекрываются отпуска {Maistrenko}
-- KB4531 - 2024-01-09 LDM: Исправление алгоритма расчета номера недели {Maistrenko}
-- KB4491 - 2023-12-22 R&D-SD:Фиксация данных для отображения по сотруднику у которого перекрываются отсутствия {Maistrenko}
-- KB2984 - 2022-02-14 BOC: Corrections to email notifications about TimeLine
-- KB2715 - 2021-10-26 Edit Fix {Efimov}
CREATE FUNCTION [dbo].[COM_DEP_VACATIONS_HTML_TABLE_NOSTYLE](@startDate date, @weeks int, @DEPID int)
returns varchar(max)
as
begin

  --/* TEST PARAMETERS */
  --declare @weeks int = 8
  --declare @DEPID int =  167 --212 --216 -- 1 prod, 2 supp dep  212-Boc-Conn
  --declare @startDate date = '20230216' --
  --/* TEST PARAMETERS */

  declare @fullday1       varchar(250) = '&#x2588;' --'█'
  declare @forenoon2      varchar(250) = '&#x2580;' --'▀'
  declare @afternoon3     varchar(250) = '&#x2584;' --'▄'
  declare @shortAbsence30 varchar(250) = '&#x25CF;' --'●'
  declare @fullday4       varchar(250) = '&#x2588;' --'█'
  declare @foreground     varchar(10)  = '·' -- '&#x2012;' --'-' -- 

  declare @appCol varchar(7)  = '#' + substring(CONVERT(varchar(max), CONVERT(VARBINARY(6), (select STATECOLOR from DEF_CLASS_STATES where CLASSOID = 1000184 and OID = 1000141)), 2),3,6)
  declare @needCol varchar(7)  = '#' + substring(CONVERT(varchar(max), CONVERT(VARBINARY(6), (select STATECOLOR from DEF_CLASS_STATES where CLASSOID = 1000184 and OID = 1000140)), 2),3,6)

  declare @DEPNAME varchar(250) = (SELECT TOP 1 DD.NAME FROM COM_DEPARTMENTS DD where DD.ID = @DEPID)

  --Дата начала стартовой недели
  declare @nowDATE date =  (select top 1 DDATE from COM_WEEK(@startDate) order by DDATE) --cast(@nowDateTime as date)

  --таблица для только нужных нам зхаписей по дкпартаментам и датам
  declare @VACATION table ([RID] int identity,EMPLID int, EMPLNAME varchar(250), DBEG date, DEND date, VACATIONTYPE int, PERIODTYPE int, S_S int, ID int)
  --заполнение этой таблицы
  insert into @VACATION
  select
    V.EMPLID, E.[NAME] as EMPLNAME, V.DBEG, isnull(V.DEND, V.DBEG), V.VACATIONTYPE, V.PERIODTYPE, V.S_S, MAX(V.ID)
    --from  [dbo].[COM_DEP_HEADS_VACATIONS]() V
  from COM_VACATION V
    left join COM_EMPLOYEE E on E.ID = V.EMPLID
  where 
    (
      (V.DBEG >= @nowDATE   /* начнуться после сегодня */
      and 
      V.DBEG < DATEADD(week,@weeks,@nowDATE)) /* начнуться не позже отображаемых недель */
    or 
      (V.DBEG <= @nowDATE  /* начнуться раньше сегодня */
        and 
      isnull(V.DEND, V.DBEG)  >= @nowDATE) /* и кончаться после сегодня */
    )
  and V.S_S in (1000140, 1000141, 2130051)--123661
  --and V.S_S not in (1000142/* KB2757 rejected*/, 1000147 /* KB2831 canceled */, 2130051 /* KB2831 Submitted to HR */, 1 /* KB2831 Created */ ) 
  and E.DEPID = @DEPID
  and V.VACATIONTYPE not in (200)
  group by
    V.EMPLID, E.[NAME], V.DBEG, isnull(V.DEND, V.DBEG), V.VACATIONTYPE, V.PERIODTYPE, V.S_S
  order by E.[NAME]

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


  /* => KB3858 - если на один и тот же период Vacation выпало и SeekLeave, то оставляем только Vacation */
  delete V1 
  from @VACATION V1
  join (select * from @VACATION where VACATIONTYPE = 10) V2 on V2.EMPLID = V1.EMPLID and V2.DBEG = V1.DBEG and V2.DEND = V1.DEND 
  where V1.VACATIONTYPE=20
  /* <= KB3858 ******************************************************************************/


  -- Удаляем те пол-дня, которые попадают в "больничный"
  -- KB4491: Пример:
  --      VACID   EMPID DBEG        DEND        DUR TYPE  UNIT  PERIOD
  --    * 251204  1891  2023-12-05  2023-12-05  0.5 10    d     2
  --    * 251548  1891  2023-12-05  2023-12-06  2   20    d     NULL
  --      252244  1891  2023-12-05  2023-12-08  4   20    d     NULL
  delete [a]
  from @VACATION [a]
    inner join @VACATION [b] on ([b].[EMPLID]=[a].[EMPLID]) and ([b].[DBEG]=[a].[DBEG]) and ([b].[RID]<>[a].[RID])
  where ([a].[PERIODTYPE] in (2,3)) and ([a].[VACATIONTYPE]=10) and ([b].[VACATIONTYPE]=20)

  -- Удаляем то отсутствие, которое меньше аналогичного на тот же период
  -- KB4491: Пример:
  --      VACID   EMPID DBEG        DEND        DUR TYPE  UNIT  PERIOD
  --      251204  1891  2023-12-05  2023-12-05  0.5 10    d     2
  --    * 251548  1891  2023-12-05  2023-12-06  2   20    d     NULL
  --    * 252244  1891  2023-12-05  2023-12-08  4   20    d     NULL
  delete [a]
  from @VACATION [a]
    inner join @VACATION [b] on ([b].[EMPLID]=[a].[EMPLID]) and ([b].[DBEG]=[a].[DBEG]) and ([b].[RID]<>[a].[RID])
  where (isnull([a].[PERIODTYPE],0)=isnull([b].[PERIODTYPE],0))
    and ([a].[VACATIONTYPE]=[b].[VACATIONTYPE])
    and ([a].[DEND] is not null)
    and ([b].[DEND] is not null)
    and ([a].[DEND]<=[b].[DEND])

  --таблица где хранить результативную информацию по имя работника и его timeline
  declare @TimeLines table (EmplName varchar(250), EmplTimeLine varchar(MAX))   

  declare @Week INT = 1;
  declare @aEmplID int   -- переменная для хранения EMPLID при перечислении всех из списка Vacations
  declare @aEmplName varchar(250)   -- переменная для хранения EMPLNAME (имени) при перечислении всех из списка Vacations
  declare @TableHead nvarchar(max) = N'<tr><th><a href="a2l:\\Link=view.com_vacation_timeline">' + @DEPNAME + N'</a></th>'

  -- Заголовок таблицы с неделями
  declare @WeekFirstDay date = @nowDATE
  set @Week = 1
  while @Week <= @Weeks
  begin
    set @TableHead = @TableHead + N'<th>CW'+ convert(nvarchar,datepart(iso_week,@WeekFirstDay)) + N'</th>'
    set @Week = @Week + 1
    set @WeekFirstDay = dateadd(week,1,@WeekFirstDay)
  end
  set @TableHead = @TableHead + N'</tr>'

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
    declare @allUserDates table ([EMPID] int,[DDATE] date,[WW] int,[VacationType] int,[PeriodType] int,[DAYN] int,[S_S] int,[YY] int,[ID] int)

    --####################### Заполняем таблицу всеми днями из всех периодов пользователя
    --объявляем курсор
    DECLARE my_cur CURSOR FOR 
     select V.DBEG, V.DEND, V.VACATIONTYPE, V.PERIODTYPE,V.S_S,V.ID
     from  @VACATION V
     where V.EMPLID = @aEmplID
    --открываем курсор
    OPEN my_cur
    --считываем данные первого периода в списке по сотруднику
    fetch next from my_cur into @bDate, @eDate, @vacationType, @periodType, @S_S, @ID
    --прока есть периоды в списке дней Vacations работника
    while @@FETCH_STATUS = 0
    begin
      --вставляем в тбалицу все дни между DBEG и DEND
      --IF ((@vacationType = 30 and NOT EXISTS(SELECT * FROM @allUserDates where DDATE = @bDate)) or @vacationType <> 30)

      if (exists(select DDATE from @allUserDates where DDATE = @bDate))
      begin
        delete from @allUserDates where DDATE = @bDate
      end

      merge @allUserDates [a]
      using(
        select
          @aEmplID [EMPID],
          DP.DDATE,
          datepart(iso_week,DP.DDATE) WW,
          @vacationType as VacationType,
          @periodType as PeriodType,
          null [DAYN],
          @S_S as S_S,
          null [YY],
          @ID as ID
        from COM_DAY_PERIOD(@bDate, @eDate) DP) [b] on [b].[EMPID]=[a].[EMPID] and [b].[DDATE]=[a].[DDATE]
      when not matched then
          insert ([EMPID],[DDATE],[WW],[VacationType],[PeriodType],[DAYN],[S_S],[YY],[ID])
          values ([b].[EMPID],[b].[DDATE],[b].[WW],[b].[VacationType],[b].[PeriodType],[b].[DAYN],[b].[S_S],[b].[YY],[b].[ID]);

          --считываем следующую данные  периода в списке по сотруднику
      fetch next from my_cur into @bDate, @eDate, @vacationType, @periodType, @S_S, @ID
    end

    CLOSE my_cur
    DEALLOCATE my_cur

     ---############# проставляем дни недели (номера 1234567) в полученный список и года
     update @allUserDates
     set DAYN = 
     (select DAYN from COM_WEEK(AUD.DDATE) CW where CW.DDATE = AUD.DDATE)
     , YY = YEAR(AUD.DDATE)
     from 
    @allUserDates AUD

    --Объявляем переменную для текстовой строки timeline (отрисовка дней недели с absence)
    DECLARE @weekTimeLine VARCHAR(max);

    --для всех искомых недель с сегодняшней (1) до какой нужно (кол-во в настройках в начале) от сегодняшней
    set @Week = 1;
    set @WeekFirstDay = @nowDATE
    WHILE @Week <= @weeks
    BEGIN
       declare @IsoWeekNumber int = datepart(iso_week,@WeekFirstDay)
      --Первая дата из недели которую проверяем
      declare @checkDate date = (select top 1 DDATE from @allUserDates where WW = @IsoWeekNumber)

      SELECT 
        @weekTimeLine = ISNULL(@weekTimeLine ,'') +

          case
            when aDAYS.DAYN = 0  then '<span class="workingday">' + @foreground + '</span>'  --нет absence
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
                        case
                          when aDAYS.S_S = 1000140 then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @fullday1 + '</span></a>'
                          else '<span class="approved">' + @fullday1 + '</span>'
                        end
                    when aDAYS.PeriodType = 2
                      then
                        case 
                          when aDAYS.S_S = 1000140 then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @forenoon2 + '</span></a>'
                          else '<span class="approved">' + @forenoon2 + '</span>' 
                        end
                    when aDAYS.PeriodType = 3
                      then
                        case
                          when aDAYS.S_S = 1000140 then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @afternoon3 + '</span></a>'
                          else '<span class="approved">' + @afternoon3 + '</span>'
                        end
                    when aDAYS.PeriodType = 4 -- полный день "переделанный" из forenoon+afternoon
                      then
                        case
                          when aDAYS.S_S = 1000140 then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @fullday4 + '</span></a>'
                          else '<span class="approved">' + @fullday4 + '</span>'
                        end
                    else
                      case
                        when aDAYS.S_S = 1000140 then '<a class="pdblink" href="a2l:\\Link=doc.com_vacation.'+ convert(varchar,aDAYS.ID) +'"><span class="needapprove">' + @fullday1 + '</span></a>'
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
          left join (select VacationType, PeriodType, S_S, DDATE, DAYN, ID from @allUserDates where WW = @IsoWeekNumber) as DATES on DATES.DDATE = ALLWEEK.DDATE
      ) aDAYS


      set @weekTimeLine = @weekTimeLine +  case when @Week = @weeks then '' else  '|' end
      set @Week = @Week + 1;
      set @WeekFirstDay = dateadd(week,1,@WeekFirstDay)
    END;

    --добавляем полдьзователя с timeline
    insert into @TimeLines
    select @aEmplName, @weekTimeLine

    set @weekTimeLine = null

    delete from  @allUserDates;

  -- перечисление aEmplID по PROD departmets
  --считываем следующую строку курсора
  FETCH NEXT FROM my_cur_empl_id INTO @aEmplID,@aEmplName
  END
  --закрываем курсор
  CLOSE my_cur_empl_id
  DEALLOCATE my_cur_empl_id


  declare @table varchar(max)
  select
    @table = ISNULL(@table,'') + 
    '<tr>' + 
      '<td nowrap style="font-family: Calibri;">' + T.EmplName + '</td>' +
      '<td nowrap>' + REPLACE(T.EmplTimeLine,'|','</td><td nowrap>') + '</td>'+
    '</tr>' + CHAR(13)
  from
    @TimeLines T
  order by
    EmplName

  set @table = '<table class="timeline">' + @TableHead +  @table +'</table>'

  declare @SUBJ varchar(max) = 'Test TABLE for report'
  declare @HTML varchar(max) =
    '<H2 class="header">' + @DEPNAME + ' Absence timeline</H2>' + CHAR(13)  
    + isnull(@table,'<H3 style="font-family: Calibri;">No Absence for period.</H3>')

  return @HTML

  --select @HTML
  --exec [dbo].[MSG_SEND_TOEMPLOYEE] 26052, 3228 , @SUBJ, @HTML
end