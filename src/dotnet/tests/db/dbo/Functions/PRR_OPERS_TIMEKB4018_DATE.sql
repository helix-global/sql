CREATE function [dbo].[PRR_OPERS_TIMEKB4018_DATE](@aEmplID int, @ddd date, @SpecOperType int, @aDepID int)
returns decimal(18,2)
as
begin

  declare @res decimal(18,2)
  
 
  declare @notByOperation int /*признак того, что этот день считать не из операций, а как "все доступное время"*/
  
  select @notByOperation = dbo.PRR_IS100PERCENT_KB4248_2(@aEmplID,@ddd)
  
  if @notByOperation = @SpecOperType
  begin
  
    /*
    в расчете за месяц используется 
    dbo.COM_WORK_MINUTS_BY_DEP3(@DepID, DBEG,case when DEND < @now2 then DEND else @now2 end,CALENDARID,EMPLID,1,2)
    теоретически за день она-же должна подойти, но в ней не вычитаются отсутствия, 
    а по смыслу из этой функции (PRR_OPERS_TIMEKB4018_DATE) должно вернуться то, что "фактически было доступно"
    по аналогии с операцими - их человек мог делать только в пределах между отсутствиями
    поэтому используем dbo.COM_ATTENDANCE_TIME4  но теперь другая - уже логическая проблема:
    мог ли этот человек посвятить "то, что было фактически было доступно" именно отчетному подразделению и его дочерним?
    COM_WORK_MINUTS_BY_DEP3 этот факт как раз учитывала.
    Поэтому прибавляем еще и COM_EMPLOYEE_IN_DEP3       
    

	KB5153:2025.01.23 Проверка что человек работал на момент операции в проверяемом отделе

    */
    
    if dbo.COM_EMPLOYEE_IN_DEP3(@aEmplID,@aDepID,@ddd,1) <> 1
    begin
		return 0
    end
	else if dbo.PRR_ISDEP_KB4664(@aDepID) = 1
	begin
		declare @allAvail2 decimal(18,2)
		select @allAvail2 = SUM(H.WORKMINUTES) 
          from COM_IMPORTED_WORKTIME H with(nolock) 
         where H.EMPLID = @aEmplID
           and H.WORKDAY = @ddd
        return isnull(@allAvail2,0)
	end
    else
    begin
		declare @allAvail decimal(12,2)
		select @allAvail = dbo.COM_ATTENDANCE_TIME4(null,@aEmplID,@ddd)
		if @allAvail is null /*and dbo.COM_IS_WORKDAY(@ddd,1) = 1 and @aDepID = 170  */
		begin
			/*т.к. COM_WORK_MINUTS_BY_DEP3 считала 8 часов если нет графика
			  если точнее, то COM_WORK_MINUTS_BY_DEP3 если нет графика считала 
			  периоды 08:00-12:00,13:00-17:00 рабочими, а также прибавляла к ним переработки 
			*/
			set @allAvail = dbo.COM_WORK_MINUTS4(@ddd, dateadd(day,1,@ddd), null, 1, @aEmplID, 1)
		end
		return isnull(@allAvail,0)
	end
  
  end
  
  select @res = sum(isnull((case when ELAPSEDCORR < 0 then 0 else ELAPSEDCORR end), ELAPSED_D)) 
  from 
    (
    select
      A.ELAPSEDCORR,
      ELAPSED_D,
      dbo.COM_EMPLOYEE_IN_DEP3(@aEmplID, @aDepID, A.DEND, 1) ISINDEP  /* KB5153*/ --проверка что на момент операции человек был в проверяемом отделе
    from
      -- Different order of tables joins per Azure#6086 "faster LUR"
      [dbo].[PR_OPERATIONS] C (nolock)
      inner hash join [dbo].[PR_OPERATION] B (nolock) on C.ID = B.OPERTYPEID and C.OPERTYPE = @SpecOperType
      join [dbo].[PR_OPERATION_TIME] A (nolock) on B.ID = A.OPERID and A.EMPID = @aEmplID

      --from PR_OPERATION_TIME A with(nolock)
      --left join PR_OPERATION B with(nolock) on B.ID = A.OPERID
      --left join PR_OPERATIONS C with(nolock) on C.ID = B.OPERTYPEID
    where 
      B.COMPLETED_DT >= @ddd
      and B.COMPLETED_DT < DATEADD(day,1,@ddd)
    ) R
	where R.ISINDEP = 1 /* KB5153*/ -- быстрее проставить потом проверить в where сразу проверять.
  option (force order) -- Azure#6086 "faster LUR"
  
  return isnull(@res,0);
  
end;