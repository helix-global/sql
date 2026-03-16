

CREATE function [dbo].[COM_VACATION_DURATION_KB3971] (@vacationID int, @DBEG date, @DEND date)
returns int
as 
begin



/*
 для задачи KB3971 вычисляем сколько в минутах бужет "стоить" отменяемое отсутсвие или отпуск в зависимости от смен и колва отменяемых дней
*/

--declare @vacationID int = 239283


declare @aDate date = @DBEG
declare @aEmployeeID int = (select TOP 1 EMPLID from COM_VACATION where ID = @vacationID)




declare @aDBEG date = DATEFROMPARTS(year(@aDate),month(@aDate),1)	-- начало месяца
declare @aDEND date = EOMONTH(@aDate,0)								-- конец месяца
declare @CalWithAllTurns table (DD date,  WEEK int, PLAN_TURN int, MINUTES decimal (10,2))		-- календарь с даты последней смены(или первого дня месяца) по последний день месяца, для проставления недель и смен


declare @firstPeriodDayWithTURN date;
declare @firstPeriodTURN int;
declare @firstPeriodDayWeek int;
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

-- проставляем время смены в минутах
update
	@CalWithAllTurns
set 
	MINUTES = PLAN_TURN_MINUTES.PLAN_MINUTES
from @CalWithAllTurns 
left join (
		-- всего минут в смене по плану согласно выбранному PERSONAL WORK TIME
		select 
			WT.WTURN, 
			SUM(DATEDIFF(minute, WT.TFROM, case when ISNULL(WT.TDEXTDAY,0) <> 0 then DATEADD(day,1,WT.TTO) else WT.TTO end)) PLAN_MINUTES
		from 
			dbo.COM_WORKTIME_BR WT with(nolock) 
			join dbo.COM_EMPLOYEE EMP with(nolock) on EMP.PERSONALWT = WT.VNESHID and EMP.ID = @aEmployeeID
		GROUP BY WT.WTURN) as PLAN_TURN_MINUTES on PLAN_TURN_MINUTES.WTURN = PLAN_TURN


-- продолжительность отменяемого VACATION
declare @cancelationDuration int
-- тип vacation
declare @vacationType int = (select VACATIONTYPE from COM_VACATION where ID = @vacationID)

-- взависимости от типа возвращаем или продолжительность короткого отсутсвия или по календарю смен
if(@vacationType = 30)
begin
	--если короткое отсутсвие
	set @cancelationDuration =  (select SHORTDURATION from COM_VACATION where ID = @vacationID)
end
else
begin
	--не короткое отсутсвие
	if((select isnull(PERIODTYPE,1) from COM_VACATION where ID = @vacationID) = 1) -- полный день
	begin
		select 
		@cancelationDuration =	SUM(CAL.MINUTES)
		from 
			@CalWithAllTurns CAL
		where 
			--CAL.DD between (select DBEG from COM_VACATION where ID = @vacationID) and (select ISNULL(DEND, DBEG) from COM_VACATION where ID = @vacationID)
			CAL.DD between @DBEG and @DEND
	end
	else
	begin
		select 
		@cancelationDuration =	SUM(CAL.MINUTES) * dbo.COM_VACATION_LEN(@vacationID,1)
		from 
			@CalWithAllTurns CAL
		where 
			--CAL.DD between (select DBEG from COM_VACATION where ID = @vacationID) and (select ISNULL(DEND, DBEG) from COM_VACATION where ID = @vacationID)
			CAL.DD between @DBEG and @DEND
	end

	
end	


return @cancelationDuration

end