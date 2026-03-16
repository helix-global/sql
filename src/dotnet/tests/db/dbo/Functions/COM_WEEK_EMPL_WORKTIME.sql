CREATE function [dbo].[COM_WEEK_EMPL_WORKTIME] (@WeekDD date, @emplid int)
returns @res table (WEEKDD date not null, DDAYOFWEEK int not null, STARTTIME datetime, ENDTIME datetime, PAUSE_MINUTES decimal(12,2), VACATIONDAY int, SHIFTN int)
as 
begin

declare @dayOfWeek int = (@@datefirst+datepart(weekday,@WeekDD)-2)%7+1;

declare @weekMonday datetime = dateadd(day,1-@dayOfWeek,@WeekDD) 
declare @weekSunday datetime = dateadd(day,7-@dayOfWeek,@WeekDD)

set @weekMonday = cast(@weekMonday as date)
set @weekSunday = cast(@weekSunday as date)

declare @nightHours int = 3

declare @emplDepGID uniqueidentifier
select @emplDepGID = B.GID
from COM_EMPLOYEE A with(nolock)
left join COM_DEPARTMENTS B with(nolock) on B.ID = A.DEPID
where A.ID = @emplid

if @emplDepGID = '27332ba0-fd72-4383-8c0a-83b99f45c50f' /* только FP для KB3596 чтобы не затронуть других для теста*/
begin
	set @nightHours = 7
end

declare @workPeriods table (IDX int primary key identity, StartTime datetime, EndTime datetime, DiffMin int, WorkDay date)

declare @oneDay date = @weekMonday
while (@oneDay <= @weekSunday)
begin
	declare @wtID int
	declare @Calendar int

	select @wtID = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@emplid,@oneDay)   
	select @Calendar = A.CALENDAR from COM_WORKTIME A with (nolock) where A.ID = @wtID
	
	declare @oneDayEnd datetime = dateadd(day,1,@oneDay)
	set @oneDayEnd = dateadd(hour,@nightHours,@oneDayEnd)

    if @wtID is not null
    begin
        if @nightHours > 3
        begin
       		insert into @workPeriods (StartTime, EndTime, DiffMin, WorkDay)
			select DBEG,DEND,datediff(mi,DBEG,DEND),WORKDAY
			from dbo.COM_TURNS_AROUND(@oneDay,@wtID,@emplid) 
			where WORKDAY = @oneDay
			and (ACTIVATEDWTURN = 1 or (ONLYONEWTURN = 1 and ISWORKDAYOFWEEK = 1/*KB4351*/))
        end
        else
        begin
			insert into @workPeriods (StartTime, EndTime, DiffMin, WorkDay)
			select DBEG,DEND,MINUTES,@oneDay from dbo.COM_WORKPERIODS5(@oneDay,@oneDayEnd,@Calendar,@wtID,@emplid)
		end	
	end	
	
	set @oneDay = dateadd(day,1,@oneDay)
end

  
declare @pausePeriods table (StartTime datetime, EndTime datetime, DiffMin int, VACATIONDAY int, TURNMIDDLE datetime,TURNSTART datetime )
insert into @pausePeriods (StartTime, EndTime, DiffMin)
select P1.EndTime, P2.StartTime, datediff(minute, P1.EndTime, P2.StartTime)
from @workPeriods P1
inner join @workPeriods P2 on P2.IDX=P1.IDX+1
where cast(P1.StartTime as date) = cast(dateadd(hour,-@nightHours,P2.StartTime) as date) /* с учетом ночных смен */
  and datediff(minute, P1.EndTime, P2.StartTime) > 0  /*KB3676*/
  

/* 
УТВЕРЖДЕННЫЕ ОТПУСКА (короткие отсутствия тоже) 
полный день отпуска очищает всё в этом дне
половинки - то что попало в половину (с учетом смены)
*/

insert into @res (WEEKDD, DDAYOFWEEK, STARTTIME , ENDTIME , PAUSE_MINUTES, VACATIONDAY, SHIFTN )
select A.DDATE
   ,(@@datefirst+datepart(weekday,A.DDATE)-2)%7+1
   ,(select min(B.StartTime) from @workPeriods B where cast(dateadd(hour,-@nightHours,B.StartTime) as date) = A.DDATE)
   ,(select max(B.EndTime) from @workPeriods B where cast(dateadd(hour,-@nightHours,B.EndTime) as date) = A.DDATE)
   /*,(select sum(F.DiffMin) from @pausePeriods F where cast(F.StartTime as date) = A.DDATE)*/
   ,(select sum(F.DiffMin) from @pausePeriods F where cast(dateadd(hour,-@nightHours,F.StartTime) as date) = A.DDATE and cast(dateadd(hour,-@nightHours,F.EndTime) as date) = A.DDATE)
   ,dbo.COM_IS_VACATIONDAY2(A.DDATE, @emplid) 
   ,dbo.COM_USER_TURN(@emplid, A.DDATE)
from dbo.COM_DAY_PERIOD(@weekMonday,@weekSunday) A

/*07.08.19*/
/*update @res set PAUSE_MINUTES = isnull(PAUSE_MINUTES,0) + dbo.COM_SHORT_ABSENCES_INDAY(WEEKDD,@emplid)*/
update @res set PAUSE_MINUTES = isnull(PAUSE_MINUTES,0) + dbo.COM_SHORT_ABSENCES_INDAY2(WEEKDD,@emplid) /*KB2867*/

/*полный день*/
update @res set STARTTIME = null , ENDTIME = null , PAUSE_MINUTES = null where VACATIONDAY = 1

/*утро - отпуск, работаем от половины смены*/
update @res set STARTTIME = dbo.COM_TURN_MIDDLE(@emplid,WEEKDD) where VACATIONDAY = 2

/*вечер - отпуск, работаем до половины смены*/
update @res set ENDTIME = dbo.COM_TURN_MIDDLE(@emplid,WEEKDD) where VACATIONDAY = 3

/*пересчет пауз по половинкам*/
if exists (select * from @res where VACATIONDAY in (2,3) and PAUSE_MINUTES > 0)
begin

  update @pausePeriods set VACATIONDAY = (select B.VACATIONDAY from @res B where B.WEEKDD = cast(dateadd(hour,-@nightHours,"@pausePeriods".EndTime) as date))
  update @pausePeriods set TURNMIDDLE = dbo.COM_TURN_MIDDLE(@emplid,dateadd(hour,-@nightHours,EndTime)) where VACATIONDAY in (2,3)
  update @pausePeriods set TURNSTART = dbo.COM_TURN_START(@emplid,dateadd(hour,-@nightHours,EndTime)) where VACATIONDAY in (3)
  
  /*пауза начиналась после начала вечернего отпуска - удалить*/
  delete from @pausePeriods where StartTime > TURNMIDDLE and VACATIONDAY = 3

  /*пауза закончилась до начала утренней половины - удалить  KB2679 */
  delete from @pausePeriods where EndTime <= TURNSTART and VACATIONDAY = 3
  
  
  /*пауза заканчивалась до окончания утреннего отпуска - удалить*/
  delete from @pausePeriods where EndTime < TURNMIDDLE and VACATIONDAY = 2
  
  /*пауза начиналась во время утреннего отпуска  - поставить время начала паузы в middle*/
  update @pausePeriods set StartTime = TURNMIDDLE where StartTime < TURNMIDDLE and VACATIONDAY = 2
  
  /*пауза заканчивалась во время вечернего отпуска  - поставить время окончания паузы в middle*/
  update @pausePeriods set EndTime = TURNMIDDLE where EndTime > TURNMIDDLE and VACATIONDAY = 3
  
  /*пересчет*/
  update @pausePeriods set DiffMin = datediff(minute, StartTime, EndTime) 
  
  update @res set PAUSE_MINUTES = (select sum(F.DiffMin) from @pausePeriods F where cast(F.StartTime as date) = "@res".WEEKDD)
  where VACATIONDAY in (2,3)

  /*07.08.19*/
  /*update @res set PAUSE_MINUTES = isnull(PAUSE_MINUTES,0) + dbo.COM_SHORT_ABSENCES_INDAY(WEEKDD,@emplid)*/
  /*TODO но похоже здесь нужно прибавлять только те короткие отсуствия, которые попали в оставшуюся половину дня,
  причем попасть может частично */
  /*KB3166*/
  update @res set PAUSE_MINUTES = isnull(PAUSE_MINUTES,0) + dbo.COM_SHORT_ABSENCES_INDAY2(WEEKDD,@emplid)
  where VACATIONDAY in (2,3)
  

end

/*KB939*/
update @res set STARTTIME = null , ENDTIME = null , PAUSE_MINUTES = null, VACATIONDAY = 1 where dbo.COM_WORK_TIME_ALLINVACATION(WEEKDD,@emplid) = 1

return
   
end