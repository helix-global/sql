

/* KB3321 calculate ALL LUR report sub reports values for month-year-deps  */

CREATE FUNCTION [dbo].[PRR_LABOR_UTILIZATION_V5_2_DEPS_SUB](@RequestID int, @IncludeCurrentMonth int ,@mode int)
RETURNS 

--храним результаты расчета Значений для кажджого отдел-месяц-год 
@res TABLE (DEPID int, [YEAR] int, [MONTH] int, DEP_AVAILABLE_PRODSUPPORT decimal (18,2), DEP_AVAILABLE_PRODSUPP_POSTED decimal (18,2), DEP_PROD_SUPP_FACTOR decimal (18,2))

AS
BEGIN


--перебираем все варианты из значения подотчетов (отдел-месяц-год )
DECLARE @DepID int
DECLARE @Month int
DECLARE @Year int

--бежим по ним
DECLARE db_cursor CURSOR FOR 
select distinct --top 2
	E.DEPID, D.MONTH, D.YEAR
from 
	PRR_LU_REPORT_REQUEST_DATA D
left 
	join COM_EMPLOYEE E with (nolock) on E.ID = D.EMPLID
where 
	D.VNESHID = @RequestID
	and E.DEPID is not null /*KB4012 fix*/
order by 
	D.MONTH, D.YEAR, E.DEPID

OPEN db_cursor  

	FETCH NEXT FROM db_cursor INTO @DepID, @Month, @Year
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	      
	    insert into @res
		select 
			T.ID,
			T.YEAR,
			T.MONTH,
			isnull(T.H_AVAILABLE_PRODSUPPORT, 0),
			isnull(T.H_AVAILABLE_PRODSUPP_POSTED, 0),
			isnull(round((case when T.H_AVAILABLE_PRODSUPPORT>0 then T.H_AVAILABLE_PRODSUPP_POSTED/T.H_AVAILABLE_PRODSUPPORT else 0 end)*100, 2),0)
		from [dbo].[PRR_LABOR_UTILIZATION_V5_2_SUM_DEP](@DEPID, @MONTH, @YEAR, @IncludeCurrentMonth, @mode) T -- высчитываем правильно по формуле числитель и знаменатель для (отдел-месяц-год)
	  
	  FETCH NEXT FROM db_cursor INTO @DepID, @Month, @Year 
	END 

CLOSE db_cursor  
DEALLOCATE db_cursor 

return
END