CREATE FUNCTION [dbo].[PRR_LABOR_UTILIZATION](@DepID int, @aMonths int)
RETURNS 
@MONTHS TABLE 
(
			 YEAR INT
			,MONTH INT
			,DBEG datetime
			,DEND datetime
			,ALLPRODUCED int          
			,EMPL_COUNT int       -- количество сотрудников
			,ALL_MH decimal(18,2)           -- всего ресурсов за вычетом отпусков
			,ALL_MH_VACATIONS decimal(18,2) -- всего ресурсов без вычета отпусков
			,ALL_MH_DELTA decimal(18,2)     -- отпуск 
			,MH_INOPERATIONS decimal(18,2)  -- всего учтено на операциях
			,MH_INOPERATIONS_INDEP decimal(18,2)  -- всего учтено на операциях только сотрудниками отдела
			,MH_INOPERATIONS_NOT_INDEP decimal(18,2) -- всего учтено на операциях только сотрудниками других отделов
			,DEV_PR decimal(16,1)        -- процент утилизации
			PRIMARY KEY (YEAR, MONTH)
)
AS
BEGIN
	
if @aMonths > 0
  return

declare @now datetime = getdate()

insert into @MONTHS (YEAR,MONTH,DBEG,DEND)
select YY,MM,DBEG,DEND_NEXT from dbo.COM_MONTH_PERIOD(dateadd(month,@aMonths,@now),dateadd(month,-1,@now)) A




update @MONTHS set ALLPRODUCED = (select count(DEV.ID)
		FROM PR_DEVICE DEV with (nolock)
		left JOIN PR_MODELS MDL with (nolock) ON DEV.MODELID = MDL.ID
		left JOIN PR_PRORDER O with (nolock) on O.ID = DEV.ORDERID
		left join PR_MODELTYPE MT with (nolock) on MT.ID = MDL.TYPEID
		WHERE O.DEPARTMENTID in (select ID from dbo.PRR_CHILD_DEPID(@DepID,1))
		  AND DEV.ORDERID IS NOT NULL
		  and DEV.COMPLETED_DT > "@MONTHS".DBEG
		  and DEV.COMPLETED_DT < "@MONTHS".DEND
		  and (isnull(MT.STATEXCLUDE,0) <> 1)
		  )


update @MONTHS set ALL_MH = dbo.PR_RESOURCES_BYDEP2(@DepID,"@MONTHS".YEAR,"@MONTHS".MONTH,1)
                  ,ALL_MH_VACATIONS = dbo.PR_RESOURCES_BYDEP2(@DepID,"@MONTHS".YEAR,"@MONTHS".MONTH,0)
				  ,EMPL_COUNT = dbo.PR_RESOURCES_BYDEP2(@DepID,"@MONTHS".YEAR,"@MONTHS".MONTH,99)
/*
update @MONTHS set MH_INOPERATIONS = (select sum(case MO.TC_ACTION when 2 then coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0) + isnull(MO.TC_MINUTE,0)
                                                                   when 1 then isnull(MO.TC_MINUTE,0)
																   else coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0) end
                                                 )
        from PR_OPERATION A with (nolock)
		left join PR_DEVICE DEV with (nolock) on DEV.ID = A.DEVICEID
		left JOIN PR_MODELS MDL with (nolock) ON DEV.MODELID = MDL.ID
		left JOIN PR_PRORDER O with (nolock) on O.ID = DEV.ORDERID
		left join PR_OPERATION_TIME TT with (nolock) on TT.OPERID = A.ID
		left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
		left join COM_EMPLOYEE EE with (nolock) on EE.ID = TT.EMPID
		WHERE --O.DEPARTMENTID in (select ID from dbo.PRR_CHILD_DEPID(@DepID,1))
		      EE.DEPID in (select ID from dbo.PRR_CHILD_DEPID(@DepID,1))
		  AND DEV.ORDERID IS NOT NULL
		  and A.S_S in (1000013,1000019)
		  and A.COMPLETED_DT > "@MONTHS".DBEG
		  and A.COMPLETED_DT < "@MONTHS".DEND
		  --and (isnull(MT.STATEXCLUDE,0) <> 1)
		  )
*/		  

update @MONTHS set MH_INOPERATIONS_INDEP = (select sum(case MO.TC_ACTION when 2 then coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0) + isnull(MO.TC_MINUTE,0)
                                                                   when 1 then isnull(MO.TC_MINUTE,0)
																   else coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0) end
                                                 )
        from PR_OPERATION_TIME TT with (nolock)
        left join PR_OPERATION A with (nolock) on A.ID = TT.OPERID
		left join PR_DEVICE DEV with (nolock) on DEV.ID = A.DEVICEID
		left JOIN PR_PRORDER O with (nolock) on O.ID = A.ORDERID
		left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
		WHERE 
		  A.ORDERID is not null
		  and A.S_S in (1000013,1000019)
		  and A.COMPLETED_DT > "@MONTHS".DBEG
		  and A.COMPLETED_DT < "@MONTHS".DEND
		  and TT.EMPID in (select TTE.ID 
		                    from COM_EMPLOYEE TTE with (nolock) where 
		                      TTE.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,1))
		                      and isnull(TTE.ROLEINDEP,0) <> 100)
		  )
		  		  


--update @MONTHS set MH_INOPERATIONS_NOT_INDEP = MH_INOPERATIONS - MH_INOPERATIONS_INDEP

update @MONTHS set DEV_PR = (MH_INOPERATIONS_INDEP / ALL_MH) * 100

update @MONTHS set ALL_MH_DELTA = ALL_MH_VACATIONS - ALL_MH
		  



	
	RETURN 
END