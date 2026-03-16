create function [dbo].[COM_WORK_MINUTS7_MODE] (@dBeg datetime, @dEnd datetime, @emplID int, @aMode int)
returns decimal(12,2)
as 
begin

	/*
	19.06.2024 по сравнению с COM_WORK_MINUTS7
	добавил @aMode чтобы, например, исключать определенные типы "отсутствий",
	которые в зависимости от трактовки: либо "отсутствия" либо "присутствия"
	*/


    declare @workM decimal(14,2);
    
    if @dBeg > @dEnd
      return 0
    

    ;
    with 
	worksall2
	  as (select A.DBEG as dbeg, A.DEND as dend, WTID from dbo.COM_WORKPERIODS8(dateadd(hour,-12,@dBeg)/*KB3804*/,dateadd(hour,12,@dEnd)/*KB4148*/,@emplID) A)
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
	,result 
	  as (select 
			case when dbeg < @dBeg then @dBeg else dbeg end as dbeg
		   ,case when dend > @dEnd then @dEnd else dend end as dend
			from mergedworks
		   )
	,resultWithWT
	  as (
		select A.dbeg,A.dend 
		      ,(select top 1 B.WTID from worksall2 B where B.dbeg >= A.dbeg order by B.dbeg) as WTID   
		  from result A
		  where A.dbeg < A.dend 
	  )	   
   select @workM = SUM( dbo.COM_DURATION_NOTVACATION_SECONDS_MODE(@emplID,A.WTID,A.dbeg,A.dend,@aMode) ) from resultWithWT A where A.dbeg < A.dend 
   set @workM = @workM / 60
    
    
   return @workM;

end