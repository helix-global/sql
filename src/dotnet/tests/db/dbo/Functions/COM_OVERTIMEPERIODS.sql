CREATE function [dbo].[COM_OVERTIMEPERIODS] (@dBeg datetime, @dEnd datetime,@emplID int,@mode int)
returns @res table (DBEG datetime, DEND datetime, DURATION decimal(18,3), NORMALWORKTIME decimal(18,3), ADDEDTIME decimal(18,3))
begin

	/*
	возвращает таблицу переработок по сотруднику 
	в поле ADDEDTIME чистое добавленное время с убранным
	попаданием рабочего времени и задвоенных записей переработок
	
	в поле NORMALWORKTIME - время стандартного рабочего времени в период переработки ( = 0 если период переработки не пересекается с нормальным рабочим временем)
	*/
    
    ;with 
	added_work  
	    as (select DATEADD(mi, DATEDIFF(mi, 0, B.DBEG), 0) as dbeg  /* без секунд и ms */
	              ,DATEADD(mi, DATEDIFF(mi, 0, B.DEND), 0) as dend  /* без секунд и ms */
	               from COM_ADDED_WORKTIME B with (nolock) where B.EMPLID = @emplID and B.DBEG < @dEnd and B.DEND > @dBeg )
	,mergedworks /* объединение периодов */ 
	 as ( 
  	   select dbeg , dend
        from 
       ( select min(dbeg) as dbeg, row_number() over(order by min(dbeg)) as rn
           from added_work s1
          where not exists (select 1 from added_work s2 where s2.dbeg < s1.dbeg and s2.dend >= s1.dbeg)
		  group by dbeg
       ) v_begin,
       ( select min(dend) as dend, row_number() over(order by min(dend)) as rn
           from added_work s1
          where not exists (select null from added_work s2 where s2.dend > s1.dend and s2.dbeg <= s1.dend)
		  group by dend
       ) v_end
       where v_begin.rn = v_end.rn
	  )  
	,result0 
	  as (select 
			case when dbeg < @dBeg then @dBeg else dbeg end as dbeg
		   ,case when dend > @dEnd then @dEnd else dend end as dend
			from mergedworks
		   )
	,result
	  as (
	      select A.dbeg
	            ,A.dend
	            ,DATEDIFF(mi,A.dbeg,A.dend) as duration
	        from result0 A
	        where A.dbeg < A.dend 
	     )
	 insert into @res (DBEG, DEND, DURATION, NORMALWORKTIME)
     select A.dbeg
          , A.dend
          , A.duration
          , dbo.COM_WORK_MINUTS_WITHOUT_ADDEDTIME(A.dbeg,A.dend,B.ID,B.CALENDAR,@emplID)
     from result A
     left join COM_WORKTIME B with (nolock) on B.ID = dbo.COM_WORKTABLE_BY_DATE(A.dbeg,@emplID)

     update @res set ADDEDTIME = DURATION - isnull(NORMALWORKTIME,0)
     update @res set ADDEDTIME = 0 where ADDEDTIME < 0

    return

end