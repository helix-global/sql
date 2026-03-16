-- =============================================
-- Author:		Maksim Efimov
-- Create date: 18.10.2023
-- Description:	Search Absence Request for Mobile TimeLine by Employee name
-- KB4360
-- KB5051 25.10.2024 - bug fix double push to Mikhail
-- =============================================
CREATE FUNCTION [dbo].[MOBILE_VACATIONS_TIMELINE_EXT](@UserID int, @UserName varchar(250))
RETURNS @t TABLE (VacationID INT, EmployeeName NVARCHAR(250), DepartmentName NVARCHAR(250), 
					DBeg NVARCHAR(100), Dend NVARCHAR(100), PeriodTypeName VARCHAR(MAX),
					ShortStart VARCHAR(5), ShortDurationName VARCHAR(MAX), VacationTypeName NVARCHAR(MAX),
					Expanded bit, SortIndex int, Remark varchar(max), State INT)  
AS
BEGIN
	
	/* TEST */
	--declare @t TABLE (VacationID INT, EmployeeName NVARCHAR(250), DepartmentName NVARCHAR(250), 
	--				DBeg NVARCHAR(100), Dend NVARCHAR(100), PeriodTypeName VARCHAR(MAX),
	--				ShortStart VARCHAR(5), ShortDurationName VARCHAR(MAX), VacationTypeName NVARCHAR(MAX),
	--				Expanded bit, SortIndex int, Remark varchar(max), State INT)
	--declare @UserID int
	--set @UserID =  26052 --26052 --453 --Фомин --19 Машкин  --857 Щербаков
	/* TEST */
	
	
	-- Tets -- Tets-- Tets-- Tets
	--if(@UserID = 26052) /* DEV Efimov for testing as IT DEP Director*/
	--begin
	--	set @UserID = 26052
	--end



	-- в нижний регистр для последующего поиска (KB4360)
	set @UserName = LOWER(@UserName);


	-- Для супербоссов меняем название отдела у простых боссов на отдел супербосса, так как по нему идет фильтр в приложении
	DECLARE @TopDepartment int = 283
	DECLARE @BossDepName varchar(200) = '';
	--Если самые главные
	if ((select top 1 B.DEPID from DEF_USERS A with (nolock) left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID where A.ID = @UserID) = @TopDepartment)
	begin
		set @BossDepName = (Select NAME from COM_DEPARTMENTS where ID = @TopDepartment)
	end
	--если начальники начальников департаментов
	else if (@UserID in (select U.ID from COM_DH_VP_SETTINGS left join DEF_USERS U on U.EMPLOYEEID = DEFAULT4EMPLID))
	begin 
		set @BossDepName = (select top 1 DEPNAME from dbo.WEB_GET_CONTEXT(@UserID))
	end


	
	--current week monday date for take vacation which visible from current week
	DECLARE @CurWeekMonDate DATE = (select DDATE from dbo.COM_WEEK(GetDate()) where DAYN=1)

	/* Inser if User who read this list is Managment for Production & Support departments */
--	insert into @t 
--	select 
--		A.ID VacationID,
--		--E.NAME EmployeeName,
--		E.SURNAME + ' ' + E.GIVENNAME as EmployeeName,
--
--		case when @BossDepName = '' then DHS.NAME else @BossDepName end as DepartmentName,
--
--		dbo.COM_FORMAT_DATETIME(A.DBEG,1) DBeg,
--		dbo.COM_FORMAT_DATETIME(A.DEND,1) Dend,
--		dbo.COM_LANG_EN(T.NAME) PeriodTypeName,
--		convert(varchar(5),convert(time,A.SHORTSTART)) ShortStart ,
--		dbo.COM_LANG_EN(TT.NAME) ShortDurationName,
--		dbo.COM_LANG_EN(TTT.NAME)  VacationTypeName,
--		case when DHST.VNESHID = UDHS.CODE then convert(bit, 1) else convert(bit, 0) end as Expanded
--	
--		,case when DHST.VNESHID = UDHS.CODE then convert(int, 10) else convert(int, 20) end SortIndex
--		
--		, A.REMARK
--		--, A.S_S
--		, case when A.S_S = 2130051 then 1000141 else A.S_S end S_S -- Если [Submitted to HR] nто это [Approved] для верного отображения в приложении как SickLeave
--
--		-- for vacation grouping
--		--,D.ID DeaprtmentID
--		--,dbo.COM_USER_DEPARTMENT(@UserID) UserDepartment
--		--,DHST.VNESHID
--		--
--		---- for current user current department group (Support or Production)
--		--,DHS.NAME
--		--,UU.ID
--		--,UU.EMPLOYEEID
--		--,UDHS.CODE
--
--	from 
--		COM_VACATION A with (nolock)
--		left join DEF_ENUMERATION_T T on T.CODE = A.PERIODTYPE and T.ENUMOID=1000120
--		left join DEF_ENUMERATION_T TT on TT.CODE = A.SHORTDURATION and TT.ENUMOID=1000122
--		left join DEF_ENUMERATION_T TTT on TTT.CODE = A.VACATIONTYPE and TTT.ENUMOID = 1000119
--		left join COM_EMPLOYEE E on E.ID = A.EMPLID
--		left join COM_DEPARTMENTS D with (nolock) on D.ID = E.DEPID
--		left join DEF_USERS U with (nolock) on U.EMPLOYEEID = A.EMPLID
--	
--		-- for vacation grouping
--		join COM_DH_VP_SETTINGS_T DHST on DHST.EMPLID = A.EMPLID
--		left join COM_DH_VP_SETTINGS DHS on DHS.CODE = DHST.VNESHID
--
--		-- for current user mange group
--		left join DEF_USERS UU with (nolock) on UU.ID = @UserID
--		left join COM_DH_VP_SETTINGS UDHS on UDHS.DEFAULT4EMPLID = UU.EMPLOYEEID
--
--	where 
--		dbo.COM_VACATION_ACCESS3(A.S_CR,A.S_S,A.EMPLID,@UserID,11,getdate())=1 
--		and
--		--A.S_S = 1000140 /* NOT approved */
--		isnull(A.DEND, A.DBEG) >= @CurWeekMonDate
--
--		and 
--		-- Начальников отделов смотрят тольбко супершефы
--		@UserID in (select dbo.COM_USER_BY_EMPL(S.DEFAULT4EMPLID) from COM_DH_VP_SETTINGS S)
--
--		and
--
--		(LOWER(E.SURNAME) like '%' + @UserName + '%'
--		or
--		LOWER(E.GIVENNAME) like '%' + @UserName + '%')
--
--
--
	/* Inser if User who read this list is Can view Absence request */
	insert into @t
	select 
		A.ID VacationID,
		--E.NAME EmployeeName,
		E.SURNAME + ' ' + E.GIVENNAME as EmployeeName,
		
		D.NAME DepartmentName,

		dbo.COM_FORMAT_DATETIME(A.DBEG,1) DBeg,
		dbo.COM_FORMAT_DATETIME(A.DEND,1) Dend,
		dbo.COM_LANG_EN(T.NAME) PeriodTypeName,
		convert(varchar(5),convert(time,A.SHORTSTART)) ShortStart ,
		dbo.COM_LANG_EN(TT.NAME) ShortDurationName,
		dbo.COM_LANG_EN(TTT.NAME)  VacationTypeName
		,case when D.ID = dbo.COM_USER_DEPARTMENT(@UserID) then convert(bit, 1) else convert(bit, 0) end as Expanded
	
		,case when D.ID = dbo.COM_USER_DEPARTMENT(@UserID) then convert(int, 30) else convert(int, 40) end SortIndex
		, A.REMARK
		--, A.S_S
		, case when A.S_S = 2130051 then 1000141 else A.S_S end S_S -- Если [Submitted to HR] ,то это [Approved] для верного отображения в приложении как SickLeave


		-- for vacation grouping
		--,D.ID DeaprtmentID
		---- for current user current department group (Support or Production)
		--,UU.ID
		--,UU.EMPLOYEEID
		--,dbo.COM_USER_DEPARTMENT(@UserID)
	from 
		COM_VACATION A with (nolock)
		left join DEF_ENUMERATION_T T on T.CODE = A.PERIODTYPE and T.ENUMOID=1000120
		left join DEF_ENUMERATION_T TT on TT.CODE = A.SHORTDURATION and TT.ENUMOID=1000122
		left join DEF_ENUMERATION_T TTT on TTT.CODE = A.VACATIONTYPE and TTT.ENUMOID = 1000119
		left join COM_EMPLOYEE E on E.ID = A.EMPLID
		left join COM_DEPARTMENTS D with (nolock) on D.ID = E.DEPID
		left join DEF_USERS U with (nolock) on U.EMPLOYEEID = A.EMPLID
	
		-- for vacation grouping
		--join COM_DH_VP_SETTINGS_T DHST on DHST.EMPLID = A.EMPLID
		--left join COM_DH_VP_SETTINGS DHS on DHS.CODE = DHST.VNESHID

		-- for current user mange group
		left join DEF_USERS UU with (nolock) on UU.ID = @UserID
		--left join COM_DH_VP_SETTINGS UDHS on UDHS.DEFAULT4EMPLID = UU.EMPLOYEEID

	where 
		--dbo.COM_VACATION_ACCESS3(A.S_CR,A.S_S,A.EMPLID,@UserID,11,getdate())=1
		A.S_S <> 1
		and
		--and 
		(
			--before 
			--dbo.DEF_USERINGROUP4(@UserID,'MNGD', getdate()) = 1 /* Mangmend Directors - Фомин, Машкин*/
			--after
			@UserID = 453 /* Фомин */ 
			or
			@UserID = 19 /* Машкин */
			or 
			@UserID = 857 /* Щербаков */ 
			or
			--@UserID = 998 /* Введенский Михаил  TEST */ 
			--or
			dbo.COM_VACATION_ACCESS3(A.S_CR,A.S_S,A.EMPLID,@UserID,11,getdate())=1
			)
		
		and
		--A.S_S = 1000140 /* NOT approved */
		isnull(A.DEND, A.DBEG) >= @CurWeekMonDate

		--and
		--U.ID <> @UserID /*Do not send to yourself*/

		and 
		(LOWER(E.SURNAME) like '%' + @UserName + '%'
		or
		LOWER(E.GIVENNAME) like '%' + @UserName + '%')

	order by Expanded desc, DepartmentName asc

	return 
END

--select * from @t