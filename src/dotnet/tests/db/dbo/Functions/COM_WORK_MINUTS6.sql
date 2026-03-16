--
-- 2025-12-04 Azure#4839: Добавлен блок mergedworks_shortdays_adjusted для учета сокращенных рабочих дней.
--
CREATE function [dbo].[COM_WORK_MINUTS6] (@dBeg datetime, @dEnd datetime, @whID int, @calendar int, @emplID int)
returns decimal(12,2)
as
begin
/* отличается от COM_WORK_MINUTS3 исключением времени по утвержденным периодам отсутствия */

  -- Debug
  -- declare @dBeg datetime = '20241231', @dEnd datetime = '20241231', @whID int = 652, @calendar int = 1, @emplID int = 4978

    declare @workM decimal(14,2);
    
    if @whID is null
    begin
      set @workM = datediff(s,@dBeg,@dEnd)
      set @workM = @workM / 60
      return @workM
      /*TODO если нет графикоа работы но попадает отпуск, то вычитать те отпуска которые полностью внутри @dBeg,@dEnd ???? */
    end;

	with
	worksall2
	  as (select A.DBEG as dbeg, A.DEND as dend from dbo.COM_WORKPERIODS(dateadd(hour,-12,@dBeg)/*KB3804*/,dateadd(hour,12,@dEnd)/*KB4148*/,@calendar,@whID,@emplID) A)
  ,short_days
    as (select DDATE, SHORTDAY from dbo.COM_DAY_PERIOD3(dateadd(hour, -12, @dBeg), dateadd(hour, 12, @dEnd), @calendar))
	,added_work  /* периоды из собственного календаря */
	    as (select DATEADD(mi, DATEDIFF(mi, 0, B.DBEG), 0) as dbeg  /* без секунд и ms */
	              ,DATEADD(mi, DATEDIFF(mi, 0, B.DEND), 0) as dend  /* без секунд и ms */
	               from COM_ADDED_WORKTIME B with (nolock) where B.EMPLID = @emplID and B.DBEG < @dEnd and B.DEND > @dBeg)
	,allworks    /* общий список периодов со своего календаря и с установленного графика */
	  as (select dbeg, dend from worksall2
	      union all
	      select dbeg, dend from added_work
	      )
	,mergedworks /* объединение периодов */
	 as (
  	   select dbeg , dend
        from
       ( select min(dbeg) as dbeg, row_number() over(order by min(dbeg)) as rn
           from allworks s1
          where not exists (select 1 from allworks s2 where s2.dbeg < s1.dbeg and s2.dend >= s1.dbeg)
		  group by dbeg
       ) v_begin,
       ( select min(dend) as dend, row_number() over(order by min(dend)) as rn
           from allworks s1
          where not exists (select null from allworks s2 where s2.dend > s1.dend and s2.dbeg <= s1.dend)
		  group by dend
       ) v_end
       where v_begin.rn = v_end.rn
	  )
  , mergedworks_shortdays_adjusted /* периоды минус короткий день, который считается как отпуск на вторую половину смены, см. функции COM_VACATION_DBEG3 / COM_VACATION_DEND3 */
    as (
        select
          case
            when isnull(sd.SHORTDAY, 0) = 0 or mw.dbeg <= turnMiddle then mw.dbeg -- не short day или период начинается до середины смены short day: оставляем
            when isnull(sd.SHORTDAY, 0) = 1 and mw.dbeg > turnMiddle then turnMiddle -- период накладывается на short day: обрезаем начало
            else mw.dbeg
          end as dbeg,
          case
            when isnull(sd.SHORTDAY, 0) = 0 or mw.dend <= turnMiddle then mw.dend -- не short day или период заканчивается до середины смены short day: оставляем
            when isnull(sd.SHORTDAY, 0) = 1 and mw.dend > turnMiddle then turnMiddle -- период накладывается на short day: обрезаем до конца раб. дня, т.е. до середины смены
            else mw.dend
          end as dend
          --,sd.*, turnMiddle
        from
          mergedworks mw
          left join short_days sd on cast(mw.dbeg as date) = sd.DDATE
          cross apply (select isnull(dbo.COM_TURN_MIDDLE(@emplID, mw.dbeg), mw.dbeg) turnMiddle) tm
    )
    --select * from mergedworks_shortdays_adjusted
	,result
	  as (select
			case when dbeg < @dBeg then @dBeg else dbeg end as dbeg
		   ,case when dend > @dEnd then @dEnd else dend end as dend
			from mergedworks_shortdays_adjusted
		   )
   select @workM = SUM( dbo.COM_DURATION_NOTVACATION_SECONDS(@emplID,@whID,A.dbeg,A.dend) ) from result A where A.dbeg < A.dend

   set @workM = @workM / 60

   return @workM;

end