
--DECLARE @DEPID int = 212
--DECLARE @aMonths int = -2

--DECLARE @IncludeCurrentMonth bit = 0
--DECLARE @mode int = 0


/* KB3321 */
CREATE FUNCTION [dbo].[PRR_LABOR_UTILIZATION_V5_2_SUM_DEP](@DepID int, @aMonth int, @aYear int, @IncludeCurrentMonth int, @mode int)
RETURNS 
@res TABLE (
	ID int,
	[YEAR] int,
	[MONTH] int,
	DBEG datetime,
	DEND datetime,
	H_AVAILABLE_PRODSUPPORT decimal (18,2),
	H_AVAILABLE_PRODSUPP_POSTED decimal (18,2)
)

AS
BEGIN

DECLARE @aDate datetime = DATEFROMPARTS(@aYear, @aMonth, 1)




insert into @res

select	@DepID ID
           ,A.YEAR
           ,A.MONTH
           ,A.DBEG
           ,A.DEND
           --,sum(A.E_INCLUDED)
           --,sum(A.H_AVAILABLE)/60
           --,sum(A.H_VACATIONS)/60
           --,sum(A.H_INOPERATIONS)/60
           --,sum(A.H_AVAILABLE_RANDD)/60
		   --,sum(A.H_INOPERATIONS_CONST)/60
           ,sum(A.H_AVAILABLE_PRODSUPPORT)/60 as H_AVAILABLE_PRODSUPPORT
		   , (
      select sum(ST.ELAPSED)
        from PR_DEVICE DEV with (nolock)
        left join PR_MODELS MDL with (nolock) ON DEV.MODELID = MDL.ID
        left join PR_PRORDER O with (nolock) on O.ID = DEV.ORDERID
        left join PR_MODELTYPE MT with (nolock) on MT.ID = MDL.TYPEID
      cross apply dbo.PR_DEVICE_PRODSUPPORT_TIME_POSTED2(DEV.ID) ST
        where O.DEPARTMENTID = @DepID  --in  (select ID from dbo.PRR_CHILD_DEPID(@DepID,1))
          AND DEV.ORDERID IS NOT NULL
          and DEV.COMPLETED_DT > A.DBEG
          and DEV.COMPLETED_DT < A.DEND
          and (isnull(MT.STATEXCLUDE,0) <> 1)
          ) / 60 as H_AVAILABLE_PRODSUPP_POSTED
		  
           
    from dbo.PRR_LABOR_UTILIZATION_V5_2_DEP(@DepID, null, @aDate, @IncludeCurrentMonth,@mode) A
    left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
    group by A.YEAR,A.MONTH,A.DBEG,A.DEND


 return

 END