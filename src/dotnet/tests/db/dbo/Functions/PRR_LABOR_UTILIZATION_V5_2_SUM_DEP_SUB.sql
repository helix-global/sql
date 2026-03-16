--DECLARE @DepID int = 82
--DECLARE @aMonth int = 8
--DECLARE @aYear int = 2022


--DECLARE @aDEPIDS varchar(MAX) = '82,84,212,213,214,215,216'

/* KB3321 */
CREATE FUNCTION dbo.PRR_LABOR_UTILIZATION_V5_2_SUM_DEP_SUB(@DepID int, @aMonth int, @aYear int)
RETURNS 
	@res TABLE (DEPID int, [YEAR] int, [MONTH] int, DBEG datetime, DEND datetime, H_AVAILABLE_PRODSUPPORT decimal, H_AVAILABLE_PRODSUPP_POSTED decimal, PROD_SUPP_FACTOR decimal)
AS
BEGIN

--constants
DECLARE @IncludeCurrentMonth int = 0
DECLARE @mode int =0


--cursor
DECLARE @DEP_FORCUR int
DECLARE db_cursor CURSOR FOR 
select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID, 1)

OPEN db_cursor  

FETCH NEXT FROM db_cursor INTO @DEP_FORCUR  
WHILE @@FETCH_STATUS = 0  
BEGIN  
      
      insert into @res
	  select T.*,  
	  round((case when T.H_AVAILABLE_PRODSUPPORT>0 then T.H_AVAILABLE_PRODSUPP_POSTED/T.H_AVAILABLE_PRODSUPPORT else 0 end)*100, 2) as PROD_SUPP_FACTOR
	  from [dbo].[PRR_LABOR_UTILIZATION_V5_2_SUM_DEP](@DEP_FORCUR, @aMonth, @aYear, @IncludeCurrentMonth, @mode) T
	  
	  --select @DEP_FORCUR as DEPID,  T.* from [dbo].[PRR_LABOR_UTILIZATION_V5_2](@DEP_FORCUR,  null, '20220701', @IncludeCurrentMonth, @mode) T
      FETCH NEXT FROM db_cursor INTO @DEP_FORCUR 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 


return
END


--select 
--	R.*,
--	round((case when R.H_AVAILABLE_PRODSUPPORT>0 then R.H_AVAILABLE_PRODSUPP_POSTED/R.H_AVAILABLE_PRODSUPPORT else 0 end)*100, 0) as PROD_SUPP_FACTOR
--from @res R