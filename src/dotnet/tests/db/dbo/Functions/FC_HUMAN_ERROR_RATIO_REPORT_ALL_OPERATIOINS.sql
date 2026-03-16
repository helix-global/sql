CREATE function [dbo].[FC_HUMAN_ERROR_RATIO_REPORT_ALL_OPERATIOINS] (@UserID int,@YearBeg  int, @YearEnd  int, @MonthBeg int, @MonthEnd int)
returns @res table (USER_ID int, OPERATION_ID int, OPERATION_NAME_ID int, OPERATION_NAME nvarchar(MAX),FAR_ID int, HER_ID int, OPERATION_COMPLETED_DT date,
					HER_CREATE_DAY int, HER_CREATE_MONTH int, HER_CREATE_YEAR int, HAS_HER int)					 
as 											 
begin										 

/* KB5152	25.03.2025	Efimov */
											 
--select DDATE dbo.COM_DAY_PERIOD( DATEFROMPARTS(@YearBeg, @MonthBeg,1), DATEADD(day,-1, DATEADD(month,1, DATEFROMPARTS(@YearEnd, @MonthEnd,1)))) CALENDAR

	/* TEST */
	--declare @UserID   int = 1537
	--declare @YearBeg  int = 2024 
	--declare @YearEnd  int = 2024 
	--declare @MonthBeg int = 1 
	--declare @MonthEnd int = 3
	/* TEST */

	declare @UserDep int = dbo.COM_USER_DEPARTMENT(@UserID)
		

	insert into @res
	select 
			USEROPER.USERID USER_ID,
			O.ID OPERATION_ID,
			OS.ID OPERATION_NAME_ID,
			OS.NAME OPERATION_NAME,
			FAR.ID FAR_ID,
			HER.ID HER_ID, 
			convert(date, O.COMPLETED_DT) OPERATION_COMPLETED_DT,  
	
			DAY(O.COMPLETED_DT) HER_CREATE_DAY,							-- is actually the date of the OPERATION to which the HER report refers (the HER created date) 
			month(O.COMPLETED_DT) HER_CREATE_MONTH,						-- is actually the date of the OPERATION to which the HER report refers (the HER created date)
			year(O.COMPLETED_DT) HER_CREATE_YEAR,						-- is actually the date of the OPERATION to which the HER report refers (the HER created date)
			case when ISNULL(HER.ID,0) = 0 then 0 else 1 end HAS_HER
		from 
			PR_OPERATION O with (nolock) 
			inner join (select OPERID,USERID from PR_OPERATION_TIME with (nolock) where USERID = @UserID group by USERID, OPERID) USEROPER on USEROPER.OPERID = O.ID 
			left join dbo.FC_REPORT FAR with (nolock) on O.ID = FAR.OPERFAILED
			/*в отчете My human error report просьба добавить условие, что HER учитываются только в статусе Feedback Requested и Feedback provided. Иначе операторы увидят HER, которые раньше были до внедрения нашей функциональности.*/
			left join dbo.FC_HUMANERROR HER with (nolock) on HER.REPORTID = FAR.ID and HER.S_S in (5290001 /*Feedback requested*/, 5290002 /*Feedback provided*/)
			left join dbo.PR_OPERATIONS OS with (nolock) on OS.ID = O.OPERTYPEID
			left join dbo.PR_PRORDER ORDERS with(nolock) on ORDERS.ID = O.ORDERID
	
		where 
		O.S_S in (1000013, 1000019, 1000038) and 
		O.ORDERID is not null
		
		
		
		
		and O.COMPLETED_DT between DATEFROMPARTS(@YearBeg, @MonthBeg,1) and DATEADD(DAY, -1, DATEADD(MONTH, 1,DATEFROMPARTS(@YearEnd, @MonthEnd,1)))
		and ORDERS.DEPARTMENTID = @UserDep


	return

end