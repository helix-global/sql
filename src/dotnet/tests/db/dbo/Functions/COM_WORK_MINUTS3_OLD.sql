create function [dbo].[COM_WORK_MINUTS3_OLD] (@dBeg datetime, @dEnd datetime, @whID int, @calendar int, @emplID int)
returns decimal(12,2)
as 
begin
/* отличается от COM_WORK_MINUTS увеличенной точночтью int -> decimal(12,2) */

    declare @workM decimal(14,2);
    
    if @whID is null
    begin
      set @workM = datediff(s,@dBeg,@dEnd)
      set @workM = @workM / 60
      return @workM
    end;

    
    with 
	worksall2
	  as (select A.DBEG as dbeg, A.DEND as dend from dbo.COM_WORKPERIODS(@dBeg,@dEnd,@calendar,@whID,@emplID) A)
	,added_work  /* периоды из собственного календаря */
	  /*as (select B.DBEG as dbeg
	              ,B.DEND as dend 
	               from COM_ADDED_WORKTIME B where B.EMPLID = @emplID and B.DBEG < @dEnd and B.DEND > @dBeg)*/
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
       ( select dbeg, row_number() over(order by dbeg) as rn
           from allworks s1
          where not exists (select null from allworks s2 where s2.dbeg < s1.dbeg and s2.dend >= s1.dbeg)
       ) v_begin,
       ( select dend, row_number() over(order by dend) as rn
           from allworks s1
          where not exists (select null from allworks s2 where s2.dend > s1.dend and s2.dbeg <= s1.dend)
       ) v_end
       where v_begin.rn = v_end.rn
	  )  
	,result 
	  as (select 
			case when dbeg < @dBeg then @dBeg else dbeg end as dbeg
		   ,case when dend > @dEnd then @dEnd else dend end as dend
			from mergedworks
		   )
   select @workM = SUM(DATEDIFF(s,A.dbeg,A.dend)) from result A where A.dbeg < A.dend 
   set @workM = @workM / 60
    
   return @workM;

end