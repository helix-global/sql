CREATE FUNCTION [dbo].[PRR_LABOR_UTILIZATION_WEEKS](@DepID int, @month int, @ww int, @year int)
RETURNS 
@res TABLE 
(
     EMPLID int    
	 , WW int
	 , YEAR int
    ,DBEG datetime
    ,DEND datetime
    ,E_INCLUDED int                  -- сотрудник учтён в этот месяц
    ,H_AVAILABLE decimal(18,2)       -- всего ресурсов 
    ,H_AVAILABLE_PLAN decimal(18,2)  -- всего ресурсов до вычета отпуска
    ,H_VACATIONS decimal(18,2)       -- отпуск
    ,H_INOPERATIONS decimal(18,2)    -- всего учтено на операциях
    ,ISRANDD int
    ,PRODSUPPORT int
    ,PARTINPRODUCTION decimal(10,4)
    ,PARTINPRODUCTIONSUPPORT decimal(10,4)
    ,PARTINRANDD decimal(18,2)    -- R&D
    ,H_AVAILABLE_RANDD decimal(18,2)    -- R&D
    ,H_INOPERATIONS_RANDD decimal(18,2) -- R&D
    ,H_AVAILABLE_PRODSUPPORT decimal(18,2)    -- оставшееся от производсвенной деятельности доступные ресурсы группы Production Support
    ,WTID int
    ,CALENDARID int
    ,H_INOPERATIONS_CONST decimal(18,2)    -- добавлено на операциях через поправки
    PRIMARY KEY (EMPLID, WW, YEAR)
)
AS
BEGIN
    
    declare @from datetime 
    declare @now datetime

	if @ww is not null
		select @from = d.DBEG, @now=d.DEND
			from dbo.COM_WEEK_FIRST_LAST_DAYS(@year,@ww) d
    else
	begin
		declare @dd datetime = dbo.COM_ENCODE_DATE(@year,@month,1)
	
		
		--select @from = d.DBEG
		--	from dbo.COM_WEEK_FIRST_LAST_DAYS(@year,DATEPART(iso_week,@dd)) d
		/* KB2951 (не верно считал недели)= */
		if @month =1 and DATEPART(iso_week,@dd) = 52
		begin --если в январе 1 неделя >1 (52 - последнфф неделя предыдущего, то год -1 у начальной недели)
			select @from = d.DBEG
				from dbo.COM_WEEK_FIRST_LAST_DAYS(@year -1 ,DATEPART(iso_week,@dd)) d --тут вычитаем
		end
		else
		begin
			select @from = d.DBEG
				from dbo.COM_WEEK_FIRST_LAST_DAYS(@year,DATEPART(iso_week,@dd)) d
		end
		
		
		set @dd = dateadd(day,-1,dateadd(month,1,@dd))
		select @now = d.DEND
			from dbo.COM_WEEK_FIRST_LAST_DAYS(@year,DATEPART(iso_week,@dd)) d
	end

	if cast(@now as date)>cast(getdate() as date)
		set @now = dateadd(minute,-1,cast(cast(getdate() as date) as datetime))


  declare @departments table (ID int primary key (ID))
  insert into @departments (ID)
  select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,1)

    declare @empl table (ID int primary key (ID))
    insert into @empl (ID)
  select distinct E.ID
  from COM_EMPLOYEE E
  left join COM_EMPL_PERIODS P on P.EMPLID=E.ID and P.DEPID in (select ID from @departments)
    where (P.ID is not null or E.DEPID in (select ID from @departments))
    and exists (select * from dbo.COM_EMPLOYEE_IN_DEP_RANGE(E.ID, @DepID, @from, @now, 1))
      and isnull(E.ROLEINDEP,0) <> 100

    declare @inoperations table (EMPLID int, WW int, YEAR int,RES decimal(18,2),CONSTADDED decimal(18,2) primary key (EMPLID,WW,YEAR))
    

    
    /* если PR_OPERATION_TIME несколько записей по одной операции то к каждой прибавлять поправки - некорректно, т.к. 
    поправка применяется ко времени всей операции  */
    /* следующий вариант прибавляет поправку к сумме нескольких записей PR_OPERATION_TIME по операции и по сотруднику                                                */
    insert into @inoperations (EMPLID,WW,YEAR,RES,CONSTADDED)
   select M.EMPID
	,M.WW
	,M.YEAR
    ,sum(case MO.TC_ACTION when 2 then M.ELAPSED + isnull(MO.TC_MINUTE,0)
                           when 1 then isnull(MO.TC_MINUTE,0)
                           else M.ELAPSED end)
    ,sum(case MO.TC_ACTION when 2 then isnull(MO.TC_MINUTE,0)
                           when 1 then isnull(MO.TC_MINUTE,0) - M.ELAPSED
                           else 0 end)
   from (
    select TT.OPERID, TT.EMPID, datepart(iso_week,A.COMPLETED_DT) as WW,year(A.COMPLETED_DT) as YEAR,sum(coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0)) as ELAPSED
    from PR_OPERATION_TIME TT with (nolock)
    left join PR_OPERATION A with (nolock) on A.ID = TT.OPERID
    left join PR_DEVICE DEV with (nolock) on DEV.ID = A.DEVICEID
    left JOIN PR_PRORDER O with (nolock) on O.ID = A.ORDERID
    left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
  left join COM_EMPL_PERIODS EP on EP.EMPLID=TT.EMPID and EP.DBEG<=A.COMPLETED_DT and (EP.DEND is null or dateadd(hour, 23, EP.DEND)>=A.COMPLETED_DT) and EP.DEPID in (select ID from @departments)
  left join COM_EMPLOYEE E on E.ID=TT.EMPID
    WHERE TT.EMPID in (select ID from @empl)
      and A.ORDERID is not null
      and A.S_S in (1000013,1000019)
      and A.COMPLETED_DT >= @from
      and A.COMPLETED_DT <= @now 
    and (EP.ID is not null or E.DEPID in (select ID from @departments))
    group by TT.OPERID, TT.EMPID,datepart(iso_week,A.COMPLETED_DT), year(A.COMPLETED_DT)
    ) M
    left join PR_OPERATION A with (nolock) on A.ID = M.OPERID
    left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
    group by M.EMPID
			,M.WW
			,M.YEAR


  declare @now2 datetime = cast(@now as date)
  set @now2 = dateadd(day,1,@now2)
  /*KB906 часы отпуска и доступные часы выровнены до одного дня для случая 
    когда текущий месяц включен - минуты последнего дня (getdate()) включаются
    полностью и в отпуска и в доступное время*/


  declare @vacations table (EMPLID int,WW int, YEAR int,RES decimal(18,2) primary key (EMPLID,WW,YEAR))
  insert into @vacations (EMPLID,WW,YEAR,RES)
    select A.EMPLID, datepart(iso_week,C.DD),year(C.DD),sum(C.MINUTES)
    from COM_VACATION A with (nolock)
    outer apply dbo.COM_VACATION_MINUTES_BYDAYS2(A.ID) C
  left join COM_EMPL_PERIODS EP on EP.EMPLID=A.EMPLID and EP.DBEG<=C.DD and (EP.DEND is null or dateadd(hour, 23, EP.DEND)>=C.DD) and EP.DEPID in (select ID from @departments)
  left join COM_EMPLOYEE E on E.ID=A.EMPLID
    where A.EMPLID in (select ID from @empl)
      and A.S_S in( 1000141,2130051)
      and isnull(A.DEND,A.DBEG) >= @from
      and dbo.COM_VACATION_OVERRIDE(A.ID,A.EMPLID,1) = 0  /*KB2254,KB2933*/
      and A.DBEG <= @now
      and C.DD is not null
      and C.DD >= @from
      and C.DD < @now2
    and (EP.ID is not null or (not exists (select * from COM_EMPL_PERIODS where EMPLID=E.ID) and E.DEPID in (select ID from @departments)))
    --and dbo.COM_EMPLOYEE_IN_DEP(A.EMPLID, @DepID, cast(C.DD as datetime))=1
    group by A.EMPLID, datepart(iso_week,C.DD),year(C.DD)
    
	insert into @res (EMPLID,YEAR,WW,DBEG,DEND,H_INOPERATIONS,H_VACATIONS,ISRANDD,PRODSUPPORT,PARTINPRODUCTION,WTID,CALENDARID,H_INOPERATIONS_CONST)
    select A.ID
          ,@year
          ,B.WW
          ,B.WEEK_MONDAY
          ,B.WEEK_SUNDAY
          ,C.RES
          ,D.RES
          ,dbo.PRR_ISRANDD2(A.ID, B.WEEK_MONDAY, B.WEEK_SUNDAY)
          ,dbo.PRR_PRODSUPPORT2(A.ID, B.WEEK_MONDAY, B.WEEK_SUNDAY)
          ,dbo.PRR_PART_IN_PROD2(A.ID, B.WEEK_MONDAY, B.WEEK_SUNDAY)
          ,isnull(E.PERSONALWT, BB.ID)
          ,isnull(BB2.CALENDAR, BB.CALENDAR)
          ,C.CONSTADDED
    from @empl A 
    cross join dbo.COM_WEEK_PERIOD4(@from,@now) B
    left join @inoperations C on C.EMPLID = A.ID and C.YEAR = B.YY and C.WW = B.WW
    left join @vacations D on D.EMPLID = A.ID and D.YEAR = B.YY and D.WW = B.WW
    left join COM_EMPLOYEE E with (nolock) on E.ID = A.ID
  left join COM_WORKTIME BB with (nolock) on BB.DEPID = E.DEPID and isnull(BB.WTDEFAULT,0) = 1 /*TODO: get worktime from history*/
  left join COM_WORKTIME BB2 with (nolock) on BB2.ID = E.PERSONALWT /*TODO: get worktime from history*/
  where exists (select * from dbo.COM_EMPLOYEE_IN_DEP_RANGE(A.ID, @DepID, B.WEEK_MONDAY, B.WEEK_SUNDAY, 1))

    
    /*
    update @res set ISRANDD = 1 where EMPLID in (14,1781)
    update @res set PRODSUPPORT = 10, PARTINPRODUCTION = 40 where EMPLID in (7,383)
    */

  update @res set H_AVAILABLE_PLAN = dbo.COM_WORK_MINUTS_BY_DEP2(@DepID, DBEG,case when DEND < @now2 then DEND else @now2 end,CALENDARID,EMPLID,1)

    --update @res set E_INCLUDED = dbo.PR_RESOURCES_BYEMPL(EMPLID,DBEG,DEND,99)
    
    update @res set E_INCLUDED = 1 where H_AVAILABLE_PLAN > 0
    
    /*если сотрудника нет (по периодам работы), а по операциям он был, то включить (?) */
    update @res set E_INCLUDED = 1 where isnull(E_INCLUDED,0) = 0 and isnull(H_INOPERATIONS,0) > 0

    /*
    update @res set H_AVAILABLE = dbo.PR_RESOURCES_BYEMPL(EMPLID,DBEG,DEND,0) - isnull(H_VACATIONS,0)
    where E_INCLUDED = 1
    */
    
    
    update @res set H_AVAILABLE = H_AVAILABLE_PLAN - isnull(H_VACATIONS,0)
    where E_INCLUDED = 1
    

    update @res 
    set H_AVAILABLE_RANDD = H_AVAILABLE * ((100 - PARTINPRODUCTION) /100)
    ,H_INOPERATIONS_RANDD = H_INOPERATIONS
    ,H_AVAILABLE = H_AVAILABLE * (PARTINPRODUCTION /100)
    --,H_INOPERATIONS = 0
    ,H_INOPERATIONS_CONST = 0
    --,PARTINPRODUCTION = 0
    ,PRODSUPPORT=0
    ,PARTINRANDD=100 - PARTINPRODUCTION
    ,PARTINPRODUCTIONSUPPORT = 0
    where ISRANDD = 1 /*Yes*/

    update @res 
    set PARTINPRODUCTIONSUPPORT = 100 - PARTINPRODUCTION
    ,PARTINRANDD=0
    ,H_AVAILABLE_PRODSUPPORT = H_AVAILABLE * ((100 - PARTINPRODUCTION) /100)
    ,H_AVAILABLE = H_AVAILABLE * (PARTINPRODUCTION /100)
    where isnull(PRODSUPPORT,0) > 0
      and isnull(PRODSUPPORT,40) < 40 /*No Support*/
      and isnull(ISRANDD,0) <> 1 /*Yes*/

    RETURN 
    
END