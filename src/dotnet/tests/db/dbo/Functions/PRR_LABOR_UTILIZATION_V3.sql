CREATE FUNCTION [dbo].[PRR_LABOR_UTILIZATION_V3](@DepID int, @aMonths int, @OnlyMonth date, @IncludeCurrentMonth int)
RETURNS 
@res TABLE 
(
	 EMPLID int    
	,YEAR INT
	,MONTH INT
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
	,H_AVAILABLE_RANDD decimal(18,2)    -- R&D
	,H_INOPERATIONS_RANDD decimal(18,2) -- R&D
	,H_AVAILABLE_PRODSUPPORT decimal(18,2)    -- оставшееся от производсвенной деятельности доступные ресурсы группы Production Support
	,WTID int
	,CALENDARID int
	,H_INOPERATIONS_CONST decimal(18,2)    -- добавлено на операциях через поправки
	PRIMARY KEY (EMPLID, YEAR, MONTH)
)
AS
BEGIN
	
	if @aMonths > 0
	  return

  set @IncludeCurrentMonth = isnull(@IncludeCurrentMonth,0)

	declare @now datetime = getdate()
	declare @from datetime 
	set @from = dateadd(month,@aMonths+@IncludeCurrentMonth,@now)
	set @from = dbo.COM_ENCODE_DATE(year(@from),month(@from),1)
	
	if @OnlyMonth is not null
	begin
	   set @from = dbo.COM_ENCODE_DATE(year(@OnlyMonth),month(@OnlyMonth),1)

      if (dateadd(month,1,@from) < @now)
      begin 
        set @now = dateadd(month,1,@from)
      end
      else
      begin 
        set @IncludeCurrentMonth = 1
      end
	end

	declare @empl table (ID int primary key (ID))
	insert into @empl (ID)
	select A.ID
	from COM_EMPLOYEE A with (nolock)
	where A.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,1))
	  and isnull(A.ROLEINDEP,0) <> 100
	  --and isnull(A.DISSDATE,'30000101') > @from

	declare @inoperations table (EMPLID int,YY int,MM int,RES decimal(18,2),CONSTADDED decimal(18,2) primary key (EMPLID,YY,MM))
	/*
	insert into @inoperations (EMPLID,YY,MM,RES,CONSTADDED)
	select TT.EMPID,year(A.COMPLETED_DT),month(A.COMPLETED_DT)
	,sum(case MO.TC_ACTION when 2 then coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0) + isnull(MO.TC_MINUTE,0)
						   when 1 then isnull(MO.TC_MINUTE,0)
						   else coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0) end)
	,sum(case MO.TC_ACTION when 2 then isnull(MO.TC_MINUTE,0)
						   when 1 then isnull(MO.TC_MINUTE,0) - coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0)
						   else 0 end)
	from PR_OPERATION_TIME TT with (nolock)
	left join PR_OPERATION A with (nolock) on A.ID = TT.OPERID
	left join PR_DEVICE DEV with (nolock) on DEV.ID = A.DEVICEID
	left JOIN PR_PRORDER O with (nolock) on O.ID = A.ORDERID
	left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
	WHERE TT.EMPID in (select ID from @empl)
	  and A.ORDERID is not null
	  and A.S_S in (1000013,1000019)
	  and A.COMPLETED_DT >= @from
	  and A.COMPLETED_DT <= @now 
	group by TT.EMPID,year(A.COMPLETED_DT),month(A.COMPLETED_DT)
	*/
	/* если PR_OPERATION_TIME несколько записей по одной операции то к каждой прибавлять поправки - некорректно, т.к. поправка применяется ко времени всей операции  */
	/* следующий вариант прибавляет поправку к сумме нескольких записей PR_OPERATION_TIME по операции и по сотруднику                                                */
	insert into @inoperations (EMPLID,YY,MM,RES,CONSTADDED)
   select M.EMPID, M.YY, M.MM 
	,sum(case MO.TC_ACTION when 2 then M.ELAPSED + isnull(MO.TC_MINUTE,0)
						   when 1 then isnull(MO.TC_MINUTE,0)
						   else M.ELAPSED end)
	,sum(case MO.TC_ACTION when 2 then isnull(MO.TC_MINUTE,0)
						   when 1 then isnull(MO.TC_MINUTE,0) - M.ELAPSED
						   else 0 end)
   from (
	select TT.OPERID, TT.EMPID, year(A.COMPLETED_DT) as YY, month(A.COMPLETED_DT) as MM ,sum(coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0)) as ELAPSED
	from PR_OPERATION_TIME TT with (nolock)
	left join PR_OPERATION A with (nolock) on A.ID = TT.OPERID
	left join PR_DEVICE DEV with (nolock) on DEV.ID = A.DEVICEID
	left JOIN PR_PRORDER O with (nolock) on O.ID = A.ORDERID
	left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
	WHERE TT.EMPID in (select ID from @empl)
	  and A.ORDERID is not null
	  and A.S_S in (1000013,1000019)
	  and A.COMPLETED_DT >= @from
	  and A.COMPLETED_DT <= @now 
    group by TT.OPERID, TT.EMPID,year(A.COMPLETED_DT),month(A.COMPLETED_DT)
    ) M
    left join PR_OPERATION A with (nolock) on A.ID = M.OPERID
    left join PR_MAP_OPER MO with (nolock) on MO.ID = A.REVOPERID
    group by M.EMPID, M.YY, M.MM 
	


    declare @vacations table (EMPLID int,YY int,MM int,RES decimal(18,2) primary key (EMPLID,YY,MM))
    insert into @vacations (EMPLID,YY,MM,RES)
	select A.EMPLID,year(C.DD),month(C.DD),sum(C.MINUTES)
	from COM_VACATION A with (nolock)
	outer apply dbo.COM_VACATION_MINUTES_BYDAYS(A.ID) C
	where A.EMPLID in (select ID from @empl)
	  and A.S_S in (1000141,2130051)
	  and isnull(A.DEND,A.DBEG) >= @from
	  and A.DBEG <= @now
	  and C.DD is not null
	group by A.EMPLID,year(C.DD),month(C.DD)
	

	insert into @res (EMPLID,YEAR,MONTH,DBEG,DEND,H_INOPERATIONS,H_VACATIONS,ISRANDD,PRODSUPPORT,PARTINPRODUCTION,WTID,CALENDARID,H_INOPERATIONS_CONST)
	select A.ID
          ,B.YY
          ,B.MM
          ,B.DBEG
          ,B.DEND_NEXT
          ,C.RES
          ,D.RES
          ,dbo.PRR_ISRANDD(A.ID, B.YY, B.MM)
          ,dbo.PRR_PRODSUPPORT(A.ID, B.YY, B.MM)
          ,dbo.PRR_PART_IN_PROD(A.ID, B.YY, B.MM)/*15.10.2018 isnull(E.PARTINPRODUCTION,100)*/
          ,isnull(E.PERSONALWT, BB.ID)
          ,isnull(BB2.CALENDAR, BB.CALENDAR)
          ,C.CONSTADDED
	from @empl A 
	cross join dbo.COM_MONTH_PERIOD(@from,dateadd(month,@IncludeCurrentMonth-1,@now)) B
	left join @inoperations C on C.EMPLID = A.ID and C.YY = B.YY and C.MM = B.MM
	left join @vacations D on D.EMPLID = A.ID and D.YY = B.YY and D.MM = B.MM
	left join COM_EMPLOYEE E with (nolock) on E.ID = A.ID
    left join COM_WORKTIME BB with (nolock) on BB.DEPID = E.DEPID and isnull(BB.WTDEFAULT,0) = 1
    left join COM_WORKTIME BB2 with (nolock) on BB2.ID = E.PERSONALWT
	
	
	/*
	update @res set ISRANDD = 1 where EMPLID in (14,1781)
	update @res set PRODSUPPORT = 10, PARTINPRODUCTION = 40 where EMPLID in (7,383)
	*/

    update @res set H_AVAILABLE_PLAN = dbo.COM_WORK_MINUTS5(DBEG,case when DEND < @now then DEND else @now end,WTID,CALENDARID,EMPLID)

    
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
    set H_AVAILABLE_RANDD = H_AVAILABLE
	,H_INOPERATIONS_RANDD = H_INOPERATIONS
	,H_AVAILABLE = 0
	,H_INOPERATIONS = 0
	,H_INOPERATIONS_CONST = 0
	,PARTINPRODUCTION = 0
	,PARTINPRODUCTIONSUPPORT = 0
    where ISRANDD = 1 /*Yes*/

    update @res 
    set PARTINPRODUCTIONSUPPORT = 100 - PARTINPRODUCTION
    ,H_AVAILABLE_PRODSUPPORT = H_AVAILABLE * ((100 - PARTINPRODUCTION) /100)
	,H_AVAILABLE = H_AVAILABLE * (PARTINPRODUCTION /100)
    where isnull(PRODSUPPORT,0) > 0
      and isnull(PRODSUPPORT,40) < 40 /*No Support*/
      and isnull(ISRANDD,0) <> 1 /*Yes*/

	RETURN 
	
END