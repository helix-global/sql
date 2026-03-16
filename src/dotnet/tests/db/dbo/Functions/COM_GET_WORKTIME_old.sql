CREATE function [dbo].[COM_GET_WORKTIME_old] (@dBeg datetime, @dEnd datetime, @aCalendarID int)
returns @res table (WORKMINUTS int, NOWORKMINUTS int ,ALLMINUTS int )
as 
begin
 
    declare @workM int ;
    
    with 
	 cte
	  as (select cast(cast(@dBeg as date) as datetime) as dt union all select dt+1 from cte where dt < cast(@dEnd as DATE))
	,workdays
	  as (select dt from cte where dbo.COM_IS_WORKDAY(dt,1) = 1)  
	,works
	  as (select cast(A.TFROM as time) as tbeg, cast(A.TTO as time) as tend
			from COM_WORKTIME_BR A where A.VNESHID = 1
		 )
	,worksall
	  as (
		  select A.dt,B.tbeg,B.tend
		  from workdays A
		  cross apply works B
		  )      
	,worksall2
	  as (
		  select dt + cast(tbeg as datetime) as dbeg, dt + cast(tend as datetime) as dend 
		  from worksall 
		  )      
	,result 
	  as (select 
			case when dbeg < @dBeg then @dBeg else dbeg end as dbeg
		   ,case when dend > @dEnd then @dEnd else dend end as dend
			from worksall2      
		   )
   select @workM = SUM(DATEDIFF(MI,A.dbeg,A.dend)) from result A where A.dbeg < A.dend 

   declare @allMinuts int 
   set @allMinuts = DATEDIFF(MI,@dBeg,@dEnd)
   
   insert into @res (WORKMINUTS,NOWORKMINUTS,ALLMINUTS)
   values (@workM, @allMinuts - @workM, @allMinuts)

   return

end