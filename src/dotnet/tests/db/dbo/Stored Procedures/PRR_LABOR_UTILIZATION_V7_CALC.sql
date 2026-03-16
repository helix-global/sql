CREATE procedure [dbo].[PRR_LABOR_UTILIZATION_V7_CALC](@RequestID int, @UserID int)
as 
BEGIN
/*
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
*/
/*
V.7  + KB3989 + KB4018
*/

delete from PRR_LU_REPORT_REQUEST_DATA where VNESHID = @RequestID
delete from PRR_LU_REPORT_REQUEST_SUM where VNESHID = @RequestID

/* KB3594 - Get date for selected ONE MONTH report */
declare @onemonthdate date = null;
declare @onemonth int
declare @onemonthmonth int
declare @creatorUserID int 
select @onemonth = isnull(ONEMONTHONLY,0)
	,@onemonthmonth =  isnull(ONEMONTHMONTH,0)
	,@creatorUserID = S_CR
from PRR_LU_REPORT_REQUEST with(nolock)
where ID = @RequestID

if @onemonth = 1 --если отмечен ONE MONTH REPORT то достаем месяц, генерим дату
begin 
	if DatePArt(month, GetDate()) < @onemonthmonth -- если выбранный месяц в этом году еще не наступил то выбираем предыдущий год
	begin
		set @onemonthdate = DATEFROMPARTS(DatePArt(year, GetDate()) - 1,@onemonthmonth,1)
	end
	else
	begin
		set @onemonthdate = DATEFROMPARTS(DatePArt(year, GetDate()),@onemonthmonth,1)
	end
end
/* KB3594 - Get date for selected ONE MONTH report */



declare @DepID int
declare @aMonths int = -12
declare @IncludeCurrentMonth int
declare @mode int
declare @remark nvarchar(max)

select @DepID = A.DEPID
	   ,@IncludeCurrentMonth = isnull(A.USECURRENTMONTH,0)
	   ,@mode = isnull(A.USEPREPARATORY,0)
	   ,@remark = cast(A.REMARK as nvarchar(max))
from PRR_LU_REPORT_REQUEST A with(nolock)
where A.ID = @RequestID

if @creatorUserID = 3 and @remark like 'old%' 
BEGIN

insert into PRR_LU_REPORT_REQUEST_DATA (VNESHID, EMPLID,YEAR,MONTH,DBEG,DEND,E_INCLUDED,H_AVAILABLE,H_AVAILABLE_PLAN
										,H_VACATIONS,H_INOPERATIONS,ISRANDD,PRODSUPPORT,PARTINPRODUCTION,PARTINPRODUCTIONSUPPORT
										,PARTINRANDD,H_AVAILABLE_RANDD,H_INOPERATIONS_RANDD,H_AVAILABLE_PRODSUPPORT
										,WTID,CALENDARID,H_INOPERATIONS_CONST,AFTER_CHANGE,OPERS_100,OPERS_101)
select @RequestID,EMPLID,YEAR,MONTH,DBEG,DEND,E_INCLUDED,H_AVAILABLE,H_AVAILABLE_PLAN
										,H_VACATIONS,H_INOPERATIONS,ISRANDD,PRODSUPPORT,PARTINPRODUCTION,PARTINPRODUCTIONSUPPORT
										,PARTINRANDD,H_AVAILABLE_RANDD,H_INOPERATIONS_RANDD,H_AVAILABLE_PRODSUPPORT
										,WTID,CALENDARID,H_INOPERATIONS_CONST,AFTER_CHANGE,OPERS_100,OPERS_101
from dbo.PRR_LABOR_UTILIZATION_V7(@DepID, @aMonths, @onemonthdate, @IncludeCurrentMonth, @mode) A


END 
ELSE 
BEGIN

insert into PRR_LU_REPORT_REQUEST_DATA (VNESHID, EMPLID,YEAR,MONTH,DBEG,DEND,E_INCLUDED,H_AVAILABLE,H_AVAILABLE_PLAN
										,H_VACATIONS,H_INOPERATIONS,ISRANDD,PRODSUPPORT,PARTINPRODUCTION,PARTINPRODUCTIONSUPPORT
										,PARTINRANDD,H_AVAILABLE_RANDD,H_INOPERATIONS_RANDD,H_AVAILABLE_PRODSUPPORT
										,WTID,CALENDARID,H_INOPERATIONS_CONST,AFTER_CHANGE,OPERS_100,OPERS_101)
select @RequestID,EMPLID,YEAR,MONTH,DBEG,DEND,E_INCLUDED,H_AVAILABLE,H_AVAILABLE_PLAN
										,H_VACATIONS,H_INOPERATIONS,ISRANDD,PRODSUPPORT,PARTINPRODUCTION,PARTINPRODUCTIONSUPPORT
										,PARTINRANDD,H_AVAILABLE_RANDD,H_INOPERATIONS_RANDD,H_AVAILABLE_PRODSUPPORT
										,WTID,CALENDARID,H_INOPERATIONS_CONST,AFTER_CHANGE,OPERS_100,OPERS_101
from dbo.PRR_LABOR_UTILIZATION_V8(@DepID, @aMonths, @onemonthdate, @IncludeCurrentMonth, @mode) A

END


/* KB3321 Calculate and update data on each subDepartments "Production support Assigment Share %" => */
/* Take lo000ng time - 1-2 min for each month-year-subDep (on BOC forexample around additional 100+ min ) */
	declare @DEP_SUB TABLE (DEPID int, [YEAR] int, [MONTH] int, DEP_AVAILABLE_PRODSUPPORT decimal (18,2), DEP_AVAILABLE_PRODSUPP_POSTED decimal(18,2), DEP_PROD_SUPP_FACTOR decimal(18,2))
	-- Calculte... Take loong time
	insert into @DEP_SUB select * from  [dbo].[PRR_LABOR_UTILIZATION_V7_DEPS_SUB](@RequestID, @IncludeCurrentMonth, @mode)
		
	update 
		[dbo].[PRR_LU_REPORT_REQUEST_DATA]
	set 
		DEP_AVAILABLE_PRODSUPPORT = DS.DEP_AVAILABLE_PRODSUPPORT,
		DEP_AVAILABLE_PRODSUPP_POSTED = DS.DEP_AVAILABLE_PRODSUPP_POSTED,
		DEP_PROD_SUPP_FACTOR = DS.DEP_PROD_SUPP_FACTOR
	FROM
		[dbo].[PRR_LU_REPORT_REQUEST_DATA]
		left join dbo.COM_EMPLOYEE E on E.ID = [dbo].[PRR_LU_REPORT_REQUEST_DATA].EMPLID
		left join @DEP_SUB DS on DS.DEPID = E.DEPID and DS.MONTH = [dbo].[PRR_LU_REPORT_REQUEST_DATA].MONTH and DS.YEAR = [dbo].[PRR_LU_REPORT_REQUEST_DATA].YEAR
	where 
		[dbo].[PRR_LU_REPORT_REQUEST_DATA].VNESHID = @RequestID
/* <= KB3321 */  

    

declare @res TABLE 
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
    /*KB4018*/
    ,AFTER_CHANGE int
    ,OPERS_100 decimal(18,2)  -- операции non-production
    ,OPERS_101 decimal(18,2)  -- операции production support
    ,H_AVAILABLE_3 decimal(18,2) -- H_AVAILABLE + H_AVAILABLE_RANDD + H_AVAILABLE_PRODSUPP
    PRIMARY KEY (DEPID, YEAR, MONTH)
)   

 insert into @res (DEPID,YEAR,MONTH,DBEG,DEND,E_INCLUDED,H_AVAILABLE,H_VACATIONS,H_INOPERATIONS,H_AVAILABLE_RANDD,H_AVAILABLE_PRODSUPP,H_INOPERATIONS_CONST
     ,AFTER_CHANGE,OPERS_100,OPERS_101)
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
           ,max(A.AFTER_CHANGE)
           ,sum(A.OPERS_100)
           ,sum(A.OPERS_101)
    from PRR_LU_REPORT_REQUEST_DATA A with(nolock)
    where A.VNESHID = @RequestID
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

    update @res set KOEFF = H_INOPERATIONS /H_AVAILABLE * 100 where H_AVAILABLE <> 0
    
    update @res set RANDD_PR = H_AVAILABLE_RANDD / H_AVAILABLE * 100 where H_AVAILABLE <> 0
    update @res set PROD_SUPP_PR = H_AVAILABLE_PRODSUPP / H_AVAILABLE * 100 where H_AVAILABLE <> 0
    
    /* > KB4018*/
    update @res set H_AVAILABLE_3 = isnull(H_AVAILABLE,0) + isnull(H_AVAILABLE_RANDD,0) + isnull(H_AVAILABLE_PRODSUPP,0) where AFTER_CHANGE = 1
    update @res set RANDD_PR = H_AVAILABLE_RANDD / H_AVAILABLE_3 * 100 where H_AVAILABLE_3 <> 0 and AFTER_CHANGE = 1
    update @res set PROD_SUPP_PR = H_AVAILABLE_PRODSUPP / H_AVAILABLE_3 * 100 where H_AVAILABLE_3 <> 0 and AFTER_CHANGE = 1    
    /* < KB4018*/
    
    
    update @res set CONST_RATIO =  H_INOPERATIONS_CONST / H_INOPERATIONS * 100 where H_INOPERATIONS > 0

    /*KB4347*/
    update @res set H_PREPARATORY = dbo.PRR_PREPARATOTYOPERS_KB4347(@DepID,"@res".DBEG,"@res".DEND)
    /*
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
    */                                        
                                        
    update @res set CONST_2PREPARATORY = dbo.PRR_PREPARATORY_PERCENTAGE(H_INOPERATIONS_CONST,H_PREPARATORY)
    
    update @res set PREPARATORY_RATIO = H_PREPARATORY / H_INOPERATIONS * 100 where H_INOPERATIONS > 0
    

   insert into PRR_LU_REPORT_REQUEST_SUM(VNESHID,DEPID,YEAR,MONTH,DBEG,DEND,E_INCLUDED,H_AVAILABLE
    ,H_VACATIONS,H_INOPERATIONS,KOEFF,PRODUCED,H_AVAILABLE_RANDD,H_AVAILABLE_PRODSUPP,H_AVAILABLE_PRODSUPP_ASSIGNED
    ,H_AVAILABLE_PRODSUPP_POSTED,RANDD_PR,PROD_SUPP_PR,H_INOPERATIONS_CONST,CONST_RATIO,H_PREPARATORY,CONST_2PREPARATORY
    ,PREPARATORY_RATIO,AFTER_CHANGE)
   select @RequestID,DEPID,YEAR,MONTH,DBEG,DEND,E_INCLUDED,H_AVAILABLE
    ,H_VACATIONS,H_INOPERATIONS,KOEFF,PRODUCED,H_AVAILABLE_RANDD,H_AVAILABLE_PRODSUPP,H_AVAILABLE_PRODSUPP_ASSIGNED
    ,H_AVAILABLE_PRODSUPP_POSTED,RANDD_PR,PROD_SUPP_PR,H_INOPERATIONS_CONST,CONST_RATIO,H_PREPARATORY,CONST_2PREPARATORY
    ,PREPARATORY_RATIO,AFTER_CHANGE
   from @res

   update PRR_LU_REPORT_REQUEST set S_S = 2130078 /*Prepared*/ where ID = @RequestID 

   exec PRR_LABOR_UTILIZATION_V6_NOTIFY @RequestID, @UserID
    
END