

CREATE function [dbo].[COM_WORK_MONTH_HOURS_KB3971] ( @aDate datetime, @aUserID int)
returns decimal(10,2)
as 
begin

declare @aDBEG date = DATEFROMPARTS(year(@aDate),month(@aDate),1)	-- начало месяца
declare @aDEND date = EOMONTH(@aDate,0)								-- конец месяца

declare @CalWithAllTurns table (DD date,  WEEK int, PLAN_TURN int)		-- календарь с даты последней смены(или первого дня месяца) по последний день месяца, для проставления недель и смен

declare @aEmployeeID int --= 3830 1157
select @aEmployeeID = (select EMPLOYEEID from dbo.DEF_USERS where ID = @aUserID)

--set @aDate datetime = '20231215'
--declare @aUserID int = 929 --33346 --1491
--declare @aEmployeeID int --= 3830 1157
--declare @res decimal(10,2) = null
/* find employeeID */

--select EMPLOYEEID from dbo.DEF_USERS where ID = 929



/* KB3971 (208,8 hours)
Пояснения Влада Киселева

1. В расчете участвуют только сотрудники, у которых на дату отмены отпуска/создания овертайма действует Personal Work Time, 
	в котором есть хотя бы одна строка c Perios Displacement=Period Starts Previous Day. Если такого нет, то проверка не отрабатывает.
2. Если проверка в п.1 пройдена, то считаем отработанные часы на дату отмены отпуска/создания овертайма. 
	Для этого по сотруднику смотрим Work Shifts и суммируем связанное рабочее время.
3. Считаем будущее рабочее время. Для этого находим последний по дате Work Shift и берем из него Turn номер. 
	Затем считаем, что до конца недели работает по этому Turn, затем если этот turn в его графике последний, то он должен иметь неделю отпуска. 
	Чтобы это проверить смотрим на вкладу Not Working Weeks. 
	Если следующая неделя соответствует по номеру неделе, указанной на этой вкладке, то следующая неделя нерабочая. 
	Если записей не найдено, то тогда калькуляция на следующую неделю идет заново с 1 смены, затем 2, и затем 3 смена.
4. Считаем переработки. Для этого идем по сотруднику в Overtime hours за месяц и суммируем все время.
5. Считаем отпуска/отсутствия. Для этого берем время по всем Absence proposals в статусе Approved и Submitted to HR. 
	И считаем по ним время в соответствии со сменой, которая должна была быть по этому графику.
6. Если это проверка на отмену отпуска, то считаем сколько часов дополнительно будет доступно у сотрудника.
7. Суммируем время п.2+п.3+п.4+п.5-п.6

*/


/* Как сделано
1. определяем последнюю заявленную смену в WorkShifts (для подсчета плановых смен по календарю)
2. от этой даты строим "вспомогательный календарь" до конца текущего месяца с неделями
3. заполняем во "вспомогательном календаре" смены по графику рабочим временем + корректируем если в эти дни были полудневные отпуски (которые не отменены)
4. берем рабочие дни в месяце (из функции - функция учитывает полнодневные отпуска и не рабочие дни, недели) 
   к ним проставляем смены из WorkShifts 
   + туда куда не подтянулись смены из WorkShifts, проставляем из "вспомогательного календаря" пункта 2 (плановые смены)

5. берем сумму минут из п.2 - это время в рабочии дни
6. берем сумму переработок за этот месяц
7. брем короткие отсутсвия (которые не были отменены)
Результат 5+6-7
*/


/* P.1 (хотя бы одна строка c Perios Displacement=Period Starts Previous Day) если нет - ВЫХОД(0) 
################################################################################################# */
if NOT EXISTS (
	select  
		WTBR.*
	from 
		dbo.COM_EMPLOYEE E with(nolock)
		left join dbo.COM_WORKTIME_BR as WTBR with(nolock) on E.PERSONALWT = WTBR.VNESHID
	where 
		E.ID = @aEmployeeID 
		and WTBR.TDEXTDAY = 2 /* Period Starts Previous Day */
	)
begin
	-- return result = 0 (no need this check)
	--return @res 
	return null;
end



/* ############################################################## */

declare @firstPeriodDayWithTURN date;
declare @firstPeriodTURN int;
declare @firstPeriodDayWeek int;

/* 1 */
-- вычисляеем меньшую дату на которую известна смена (она может быть не в текущем месяце) или 1 числа текущего месяца(если есть)
-- номер смены в эту дату 
-- и номер недели этой даты(смены)
-- для заполнения календаря реальных отработанных смен и будущих
select 
	top 1
	@firstPeriodDayWithTURN = T.DD,
	@firstPeriodTURN = T.WTURN,
	@firstPeriodDayWeek = P.WW
	--T.DD,
	--T.WTURN,
	--P.WW
from 
	dbo.COM_TURNS T with(nolock)
	left join dbo.COM_WEEK_PERIOD4(@aDBEG, @aDEND) P on T.DD between P.WEEK_MONDAY and P.WEEK_SUNDAY
where 
	T.EMPLID = @aEmployeeID and T.DD <= @aDBEG
order by T.DD DESC

--select @firstPeriodDayWithTURN, @firstPeriodTURN, @firstPeriodDayWeek

/* 2 */
-- заполняем календарь с последней даты на которую проставлена смена в COM_TURNS до окончания расчетного месяца 
insert into @CalWithAllTurns (DD, PLAN_TURN, WEEK)
select 
	CAL.DDATE,
	case when CAL.DDATE = @firstPeriodDayWithTURN then @firstPeriodTURN else null end,
	P.WW
from 
	dbo.COM_DAY_PERIOD(@firstPeriodDayWithTURN,@aDEND) CAL
	left join dbo.COM_WEEK_PERIOD4(@firstPeriodDayWithTURN,@aDEND) P on CAL.DDATE between P.WEEK_MONDAY and P.WEEK_SUNDAY

/* 3 */
-- курсор для вычисления и проставления будущих смен
DECLARE @DD date --проверяемая дата
DECLARE cal_cursor CURSOR FOR 

SELECT DD FROM @CalWithAllTurns WHERE PLAN_TURN is null ORDER BY DD --все даты без проставленных смен по порядку даты

OPEN cal_cursor  
FETCH NEXT FROM cal_cursor INTO @DD  

WHILE @@FETCH_STATUS = 0  
BEGIN  
      if((select WEEK from @CalWithAllTurns where DD = @DD) <> @firstPeriodDayWeek)		 
	  -- если неделя смменилась 
	  begin
		-- вычисляем номер следующей смены по схеме 1,2,3,0 - где 0 - смена на выходной неделе (не рабочая неделя)
	    if(@firstPeriodTURN = 3)
			set @firstPeriodTURN = 0
		else
			set @firstPeriodTURN = @firstPeriodTURN + 1
		-- увеличиваем неделю
		set @firstPeriodDayWeek = @firstPeriodDayWeek +1
	  end

	  -- проставляем смену на проверяемую дату в календаре
	  update @CalWithAllTurns 
		set PLAN_TURN = @firstPeriodTURN 
		where DD = @DD

      FETCH NEXT FROM cal_cursor INTO @DD
END 

CLOSE cal_cursor  
DEALLOCATE cal_cursor

--select * from @CalWithAllTurns

/* 4 */
-- календарь рабочих дней за вычетом отпуксков и нераюбочих недель, дней и вычетом полдневных отпусков(n) из времени работы в смене
declare @aWorkDaysWithTurns table (DDATE date, TURN int, MINUTES decimal(10,2))
insert into @aWorkDaysWithTurns

select 
	WORKDAYS.DDATE 
	--,T.WTURN FACT_TRUN--указнная рабочая смена из запелненного WorkShifts
	--,CALPLAN.PLAN_TURN PLAN_TURN--,dbo.COM_USER_TURN(@aEmployeeID, T.DDATE)
	,case when T.WTURN is null then CALPLAN.PLAN_TURN else T.WTURN end CALC_TURN
	--,PLAN_TURN_MINUTES.PLAN_MINUTES
	,PLAN_TURN_MINUTES.PLAN_MINUTES - convert(decimal(10,2),PLAN_TURN_MINUTES.PLAN_MINUTES)/2  * isnull(VAC_HALF_DAY.HALF_DAYS_COUNT,0)  -- отнимает время пол смены, такое кол-во раз сколько есть на этот день полдневных отпусков (по идее 1 или 2)

from 
	dbo.COM_WORK_DAYS_TAB(@aDBEG,@aDEND, @aEmployeeID) WORKDAYS							-- рабочие дни в месяце
	left join dbo.COM_TURNS T with(nolock) on T.DD = WORKDAYS.DDATE and T.EMPLID = @aEmployeeID	-- отмесченные смены
	left join @CalWithAllTurns CALPLAN on CALPLAN.DD = WORKDAYS.DDATE and T.WTURN is null		-- плановые (расчитанные) смены
	left join (
		-- всего минут в смене по плану согласно выбранному PERSONAL WORK TIME
		select 
			WT.WTURN, 
			SUM(DATEDIFF(minute, WT.TFROM, case when ISNULL(WT.TDEXTDAY,0) <> 0 then DATEADD(day,1,WT.TTO) else WT.TTO end)) PLAN_MINUTES
		from 
			dbo.COM_WORKTIME_BR WT with(nolock) 
			join dbo.COM_EMPLOYEE EMP with(nolock) on EMP.PERSONALWT = WT.VNESHID and EMP.ID = @aEmployeeID
		GROUP BY WT.WTURN) as PLAN_TURN_MINUTES on PLAN_TURN_MINUTES.WTURN = (case when T.WTURN is null then CALPLAN.PLAN_TURN else T.WTURN end)
	left join (
		-- количесвто отпусков по пол дня в искомые даты, если есть
		select 
			--VAC.*
			VAC.DBEG, COUNT(VAC.ID) HALF_DAYS_COUNT
		from 
			COM_VACATION VAC 
			-- отмененные vacation
			left join COM_VACATION_CANCEL VACCANCEL with (nolock) ON VACCANCEL.VACATIONID = VAC.ID and VACCANCEL.S_S in (1000160 /* Approved */, 2130053 /* Submitted to HR  */)  
		where
			VAC.EMPLID = @aEmployeeID	-- сотрудник
			and VAC.VACATIONTYPE = 10 /* Short absence */  and isnull(VAC.PERIODTYPE,0) <> 1
			and VAC.S_S in  (1000141 /* Approved */, 2130051 /* Submitted to HR  */) -- утвержденные короткие отсутствия
			and VAC.ID in (250349,250908,252022)
			and VACCANCEL.ID is null -- не отмененные
		group by VAC.DBEG) VAC_HALF_DAY on VAC_HALF_DAY.DBEG = WORKDAYS.DDATE


/* 5 */
--work time TURNS
declare @WORK_TURNS_TIME decimal(10,2) = (select SUM(MINUTES) from @aWorkDaysWithTurns)
/* 6 */
--overtimes
declare @OVERTIMES_TIME decimal(10,2) = (select SUM(ADDEDTIME) from COM_OVERTIMEPERIODS(@aDBEG,@aDEND, @aEmployeeID,1))
/* 7 */
--shortabsence
declare @SHORT_TIME decimal(10,2) =
(select 
	SUM(isnull(VAC.SHORTDURATION,0))
from 
	COM_VACATION VAC 
	-- отмененные vacation
	left join COM_VACATION_CANCEL VACCANCEL with (nolock) ON VACCANCEL.VACATIONID = VAC.ID and VACCANCEL.S_S in (1000160 /* Approved */, 2130053 /* Submitted to HR  */)  
where
	VAC.EMPLID = @aEmployeeID	-- сотрудник
	and VAC.VACATIONTYPE = 30 /* Short absence */ and VAC.S_S in  (1000141 /* Approved */, 2130051 /* Submitted to HR  */) -- утвержденные короткие отсутствия
	and VACCANCEL.ID is null	-- не отмененные
	and MONTH(VAC.DBEG) = MONTH(@aDBEG) and YEAR(VAC.DBEG) = YEAR(@aDBEG) -- текущий месяц
)


-- TEST ###################################################################
--select * from @aWorkDaysWithTurns
--select * from COM_OVERTIMEPERIODS(@aDBEG,@aDEND, @aEmployeeID,1)
--select 
--	VAC.*
--from 
--	COM_VACATION VAC 
--	-- отмененные vacation
--	left join COM_VACATION_CANCEL VACCANCEL with (nolock) ON VACCANCEL.VACATIONID = VAC.ID and VACCANCEL.S_S in (1000160 /* Approved */, 2130053 /* Submitted to HR  */)  
--where
--	VAC.EMPLID = @aEmployeeID	-- сотрудник
--	and VAC.VACATIONTYPE = 30 /* Short absence */ and VAC.S_S in  (1000141 /* Approved */, 2130051 /* Submitted to HR  */) -- утвержденные короткие отсутствия
--	and VACCANCEL.ID is null	-- не отмененные
--	and MONTH(VAC.DBEG) = MONTH(@aDBEG) and YEAR(VAC.DBEG) = YEAR(@aDBEG) -- текущий месяц
-- TEST ###################################################################

--select @WORK_TURNS_TIME WORK_TURNS_TIME, @OVERTIMES_TIME OVERTIMES_TIME, @SHORT_TIME SHORT_TIME, 
--		 isnull(@WORK_TURNS_TIME,0) + isnull(@OVERTIMES_TIME,0) - isnull(@SHORT_TIME,0) TOTAL


return (isnull(@WORK_TURNS_TIME,0) + isnull(@OVERTIMES_TIME,0) - isnull(@SHORT_TIME,0))/60

end