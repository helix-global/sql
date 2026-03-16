CREATE FUNCTION [dbo].[PRR_LABOR_UTILIZATION_V4_SUM](@DepID int, @aMonths int, @IncludeCurrentMonth int)
RETURNS 
@res TABLE 
(
	 DEPID int    
	,YEAR INT
	,MONTH INT
	,DBEG datetime
	,DEND datetime
	,E_INCLUDED int                      -- сотрудников, учтённых в этот месяц
	,H_AVAILABLE decimal(18,2)           -- всего ресурсов - отпуск
	,H_VACATIONS decimal(18,2)           -- отпуск
	,H_INOPERATIONS decimal(18,2)        -- всего учтено на операциях
	,KOEFF decimal(18,2)                 -- коефф. утилизации (%)
	,PRODUCED int                        -- количество произведенных изделий
	,H_AVAILABLE_RANDD decimal(18,2)     -- 100% ресурсов по R&D сотрудникам, это значение не входит в H_AVAILABLE
	,H_AVAILABLE_PRODSUPP decimal(18,2)  -- часть ресурсов по Production Support сотрудникам, который не входит в H_AVAILABLE
	,H_AVAILABLE_PRODSUPP_ASSIGNED decimal(18,2)  -- часть ресурсов по Production Support, который считается на основании добавок PR_REV_ADD_TIMES (PRODSUPPORT=1)
	,H_AVAILABLE_PRODSUPP_POSTED decimal(18,2)  -- часть ресурсов по Production Support, который считается на основании PR_DEVICE_PROD_SUPP
	,RANDD_PR decimal(16,1)              -- процент R&D ресурсов ко всем ресурсам
	,PROD_SUPP_PR decimal(16,1)          -- процент оставшихся Production Support ресурсов ко всем ресурсам
	,H_INOPERATIONS_CONST decimal(18,2)  -- добавлено на операциях через поправки
	,CONST_RATIO decimal(16,1)           -- процент поправок к времени операции
	,H_PREPARATORY decimal(16,1)         -- время подготовительных операций в целом по отделу за тот-же месяц
	,CONST_2PREPARATORY decimal(16,1)    -- процент  времени подготовительных операций в целом по отделу за месяц к поправкам, вошедшим во время операции 
	,PREPARATORY_RATIO decimal(16,1)     -- процент  времени подготовительных операций к учтенному
	PRIMARY KEY (DEPID, YEAR, MONTH)
)
AS
BEGIN
	
	if @aMonths > 0
	  return
	
	insert into @res (DEPID,YEAR,MONTH,DBEG,DEND,E_INCLUDED,H_AVAILABLE,H_VACATIONS,H_INOPERATIONS,H_AVAILABLE_RANDD,H_AVAILABLE_PRODSUPP,H_INOPERATIONS_CONST)
	select @DepID
	       ,A.YEAR
	       ,A.MONTH
	       ,A.DBEG
	       ,A.DEND
	       ,sum(A.E_INCLUDED)
	       ,sum(A.H_AVAILABLE)/60
	       ,sum(A.H_VACATIONS)/60
	       ,sum(A.H_INOPERATIONS)/60
	       ,sum(A.H_AVAILABLE_RANDD)/60
	       ,sum(A.H_AVAILABLE_PRODSUPPORT)/60
	       ,sum(A.H_INOPERATIONS_CONST)/60
	from dbo.PRR_LABOR_UTILIZATION_V4(@DepID, @aMonths, null, @IncludeCurrentMonth) A
    left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
	group by A.YEAR,A.MONTH,A.DBEG,A.DEND
	
	update @res set PRODUCED = (select count(DEV.ID)
		FROM PR_DEVICE DEV with (nolock)
		left JOIN PR_MODELS MDL with (nolock) ON DEV.MODELID = MDL.ID
		left JOIN PR_PRORDER O with (nolock) on O.ID = DEV.ORDERID
		left join PR_MODELTYPE MT with (nolock) on MT.ID = MDL.TYPEID
		WHERE O.DEPARTMENTID in (select ID from dbo.PRR_CHILD_DEPID(@DepID,1))
		  AND DEV.ORDERID IS NOT NULL
		  and DEV.COMPLETED_DT > "@res".DBEG
		  and DEV.COMPLETED_DT < "@res".DEND
		  and (isnull(MT.STATEXCLUDE,0) <> 1)
		  )
	
	update @res set H_AVAILABLE_PRODSUPP_ASSIGNED = 
    (
      select sum(ST.ELAPSED)
  		from PR_DEVICE DEV with (nolock)
  		left join PR_MODELS MDL with (nolock) ON DEV.MODELID = MDL.ID
  		left join PR_PRORDER O with (nolock) on O.ID = DEV.ORDERID
  		left join PR_MODELTYPE MT with (nolock) on MT.ID = MDL.TYPEID
      cross apply dbo.PR_DEVICE_PRODSUPPORT_TIME(DEV.ID) ST
  		where O.DEPARTMENTID in (select ID from dbo.PRR_CHILD_DEPID(@DepID,100/*KB3843*/))
  		  AND DEV.ORDERID IS NOT NULL
  		  and DEV.COMPLETED_DT > "@res".DBEG
  		  and DEV.COMPLETED_DT < "@res".DEND
  		  and (isnull(MT.STATEXCLUDE,0) <> 1)
		  ) / 60
	
	update @res set H_AVAILABLE_PRODSUPP_POSTED = 
    (
      select sum(ST.ELAPSED)
  		from PR_DEVICE DEV with (nolock)
  		left join PR_MODELS MDL with (nolock) ON DEV.MODELID = MDL.ID
  		left join PR_PRORDER O with (nolock) on O.ID = DEV.ORDERID
  		left join PR_MODELTYPE MT with (nolock) on MT.ID = MDL.TYPEID
      cross apply dbo.PR_DEVICE_PRODSUPPORT_TIME_POSTED2(DEV.ID) ST
  		where O.DEPARTMENTID in (select ID from dbo.PRR_CHILD_DEPID(@DepID,100/*KB3843*/))
  		  AND DEV.ORDERID IS NOT NULL
  		  and DEV.COMPLETED_DT > "@res".DBEG
  		  and DEV.COMPLETED_DT < "@res".DEND
  		  and (isnull(MT.STATEXCLUDE,0) <> 1)
		  ) / 60

    update @res set KOEFF = H_INOPERATIONS /H_AVAILABLE * 100
    
    update @res set RANDD_PR = H_AVAILABLE_RANDD / H_AVAILABLE * 100
    update @res set PROD_SUPP_PR = H_AVAILABLE_PRODSUPP / H_AVAILABLE * 100
    
    update @res set CONST_RATIO =  H_INOPERATIONS_CONST / H_INOPERATIONS * 100 where H_INOPERATIONS > 0

    update @res set H_PREPARATORY = (select sum(coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0)) 
                                       from PR_OPERATION_TIME TT with (nolock)
	                              left join PR_OPERATION A with (nolock) on A.ID = TT.OPERID
	                              left join COM_EMPLOYEE E with (nolock) on E.ID = TT.EMPID
		                              WHERE A.ORDERID is null
		                                and A.EQID is null
		                                and E.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,1))
	                                    and A.S_S in (1000013,1000019)
	                                    and A.COMPLETED_DT > "@res".DBEG
	                                    and A.COMPLETED_DT < "@res".DEND ) / 60
	                                    
    update @res set CONST_2PREPARATORY = dbo.PRR_PREPARATORY_PERCENTAGE(H_INOPERATIONS_CONST,H_PREPARATORY)
    
    update @res set PREPARATORY_RATIO = H_PREPARATORY / H_INOPERATIONS * 100 where H_INOPERATIONS > 0
	
	RETURN 
	
END