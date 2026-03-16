CREATE function [dbo].[COM_WORK_MINUTS5] (@dBeg datetime, @dEnd datetime, @whID int, @calendar int, @emplID int)
returns decimal(12,2)
as 
begin

    /* без учета отпусков, но с учетом "периодов трудоустройства" (COM_WORKPERIODS3) */

    declare @workM decimal(14,2);
    
    with 
	worksall2
	  as (select A.DBEG as dbeg, A.DEND as dend from dbo.COM_WORKPERIODS3(dateadd(hour,-12,@dBeg)/*KB3804*/,dateadd(hour,12,@dEnd)/*KB4148*/,@calendar,@whID,@emplID) A where A.DBEG < @dEnd)
	,added_work  
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
	            ,DATEDIFF(mi,A.dbeg,A.dend) as duration_s
	        from result0 A
	        where A.dbeg < A.dend 
	     )
   select @workM = SUM(duration_s) from result A 
   
    
   return @workM;

end