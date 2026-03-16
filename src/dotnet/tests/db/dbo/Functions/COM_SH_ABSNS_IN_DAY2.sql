CREATE function [dbo].[COM_SH_ABSNS_IN_DAY2] (@emplID int, @aDate date, @aIncludeID int)
returns int
as 
begin

	/*в отличие от COM_SH_ABSNS_IN_DAY, ID, который идет последним параметром
	  не исключается, а обязательно включается в подсчет */

   /*add: считает только рабочие минуты внутри отсутствия */	  
   declare @wtID int
   declare @Calendar int
   
   select @wtID = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@emplID,@aDate)   
   select @Calendar = A.CALENDAR from COM_WORKTIME A with (nolock) where A.ID = @wtID
	  
 
    declare @res int;
    
    with 
      allworks     
	  as (select dbo.COM_VACATION_DBEG(A.ID) as dbeg
	            ,dbo.COM_VACATION_DEND(A.ID) as dend
	      from COM_VACATION A with(nolock)
	      where A.EMPLID = @emplID
	        and A.VACATIONTYPE = 30
            and A.DBEG = @aDate
            and A.ID <> ISNULL(@aIncludeID,-54656)
            and A.S_S in (1000141, 1000140, 2130051) 
          union all 
			select dbo.COM_VACATION_DBEG(A.ID) as dbeg
	              ,dbo.COM_VACATION_DEND(A.ID) as dend
	      from COM_VACATION A with(nolock)          
			where A.ID = @aIncludeID            
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
	  as (
	  select dbeg, dend from mergedworks where dbeg < dend
		  )
	  select @res = SUM(dbo.COM_WORK_MINUTS5(A.dbeg,A.dend,@wtID,@Calendar,@emplID)) from result A where A.dbeg < A.dend 
      --select @res = SUM(DATEDIFF(MI,A.dbeg,A.dend)) from result A where A.dbeg < A.dend 
   
   

   return @res

end