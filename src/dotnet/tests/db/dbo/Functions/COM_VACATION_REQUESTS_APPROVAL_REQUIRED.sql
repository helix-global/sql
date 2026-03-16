-- =============================================
-- Author:		Maksim Efimov
-- Create date: 06.05.20222
-- Description:	Get list of Absence Request can be approved/rejected by user
-- 
-- 
-- =============================================
CREATE FUNCTION [dbo].[COM_VACATION_REQUESTS_APPROVAL_REQUIRED](@UserID int)
RETURNS @t TABLE (VacationID INT, EmployeeName NVARCHAR(250), DepartmentName NVARCHAR(250), 
					DBeg NVARCHAR(100), Dend NVARCHAR(100), PeriodTypeName VARCHAR(MAX),
					ShortStart VARCHAR(5), ShortDurationName VARCHAR(MAX), VacationTypeName NVARCHAR(MAX),
					Expanded bit, SortIndex int, Remark varchar(max), CreateDT datetime)  
AS
BEGIN
	
	
	/* CHANGES */
	-- 17.04.2024	Fix "Bug" when mobile App crush. In list of absence for top managment (Mashkin and Fomin) was included wrong information with Dep. Name with NULL values
	-- 07.01.2025   Fix "Bug" for view only IGPL heads  (DHS.CODE in (1,2)) do not show POLAND and etc for Mashkin - only Production & Support departments

	
	/* TEST */
	--declare @t TABLE (VacationID INT, EmployeeName NVARCHAR(250), DepartmentName NVARCHAR(250), 
	--				DBeg NVARCHAR(100), Dend NVARCHAR(100), PeriodTypeName VARCHAR(MAX),
	--				ShortStart VARCHAR(5), ShortDurationName VARCHAR(MAX), VacationTypeName NVARCHAR(MAX),
	--				Expanded bit, SortIndex int, Remark varchar(max))
	--declare @UserID int
	--set @UserID =  453 --26052 --453 --Фомин --19 Машкин  --857 Щербаков
	/* TEST */




	/* Inser if User who read this list is Managment for Production & Support departments */
	insert into @t 
	select 
		A.ID VacationID,
		E.NAME EmployeeName,
	
		--D.NAME DepartmentName,
		DHS.NAME DepartmentName,

		dbo.COM_FORMAT_DATETIME(A.DBEG,1) DBeg,
		dbo.COM_FORMAT_DATETIME(A.DEND,1) Dend,
		dbo.COM_LANG_EN(T.NAME) PeriodTypeName,
		convert(varchar(5),convert(time,A.SHORTSTART)) ShortStart ,
		dbo.COM_LANG_EN(TT.NAME) ShortDurationName,
		dbo.COM_LANG_EN(TTT.NAME)  VacationTypeName,
		case when DHST.VNESHID = UDHS.CODE then convert(bit, 1) else convert(bit, 0) end as Expanded
	
		,case when DHST.VNESHID = UDHS.CODE then convert(int, 10) else convert(int, 20) end SortIndex
		
		, A.REMARK
		
		-- for vacation grouping
		--,D.ID DeaprtmentID
		--,dbo.COM_USER_DEPARTMENT(@UserID) UserDepartment
		--,DHST.VNESHID
		--
		---- for current user current department group (Support or Production)
		--,DHS.NAME
		--,UU.ID
		--,UU.EMPLOYEEID
		--,UDHS.CODE
		, A.S_CDT 

	from 
		COM_VACATION A with (nolock)
		left join DEF_ENUMERATION_T T with(nolock) on T.CODE = A.PERIODTYPE and T.ENUMOID=1000120
		left join DEF_ENUMERATION_T TT with(nolock) on TT.CODE = A.SHORTDURATION and TT.ENUMOID=1000122
		left join DEF_ENUMERATION_T TTT with(nolock) on TTT.CODE = A.VACATIONTYPE and TTT.ENUMOID = 1000119
		left join COM_EMPLOYEE E with(nolock) on E.ID = A.EMPLID
		left join COM_DEPARTMENTS D with (nolock) on D.ID = E.DEPID
		left join DEF_USERS U with (nolock) on U.EMPLOYEEID = A.EMPLID
	
		-- for vacation grouping
		join COM_DH_VP_SETTINGS_T DHST with(nolock) on DHST.EMPLID = A.EMPLID
		join COM_DH_VP_SETTINGS DHS with(nolock) on DHS.CODE = DHST.VNESHID

		-- for current user mange group
		left join DEF_USERS UU with (nolock) on UU.ID = @UserID
		left join COM_DH_VP_SETTINGS UDHS with(nolock) on UDHS.DEFAULT4EMPLID = UU.EMPLOYEEID

	where 
		(dbo.COM_VACATION_ACCESS3(A.S_CR,A.S_S,A.EMPLID,@UserID,11,getdate())=1 
			--or
		 --@UserID = 26052 /* DEV Efimov for TEST*/
		)

		and
		A.S_S = 1000140 /* NOT approved */

		and 
		-- Начальников отделов смотрят тольбко супершефы
		(@UserID in (select dbo.COM_USER_BY_EMPL(S.DEFAULT4EMPLID) from COM_DH_VP_SETTINGS S) )
		and
		A.VACATIONTYPE<>20 /*NOT sick leave*/
		and

		DHS.CODE in (1,2) /* fix for view only IGPL heads  (07.01.2025 Efimov) */


	/* Inser if User who read this list is Can view Absence request */
	insert into @t
	select 
		A.ID VacationID,
		E.NAME EmployeeName,
	
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
		, A.S_CDT
		-- for vacation grouping
		--,D.ID DeaprtmentID
		---- for current user current department group (Support or Production)
		--,UU.ID
		--,UU.EMPLOYEEID
		--,dbo.COM_USER_DEPARTMENT(@UserID)
	from 
		COM_VACATION A with (nolock)
		left join DEF_ENUMERATION_T T with(nolock) on T.CODE = A.PERIODTYPE and T.ENUMOID=1000120
		left join DEF_ENUMERATION_T TT with(nolock) on TT.CODE = A.SHORTDURATION and TT.ENUMOID=1000122
		left join DEF_ENUMERATION_T TTT with(nolock) on TTT.CODE = A.VACATIONTYPE and TTT.ENUMOID = 1000119
		left join COM_EMPLOYEE E with(nolock) on E.ID = A.EMPLID
		left join COM_DEPARTMENTS D with (nolock) on D.ID = E.DEPID
		left join DEF_USERS U with (nolock) on U.EMPLOYEEID = A.EMPLID
	
		-- for vacation grouping
		--join COM_DH_VP_SETTINGS_T DHST on DHST.EMPLID = A.EMPLID
		--left join COM_DH_VP_SETTINGS DHS on DHS.CODE = DHST.VNESHID

		-- for current user mange group
		left join DEF_USERS UU with (nolock) on UU.ID = @UserID
		--left join COM_DH_VP_SETTINGS UDHS on UDHS.DEFAULT4EMPLID = UU.EMPLOYEEID

	where 
		
		(dbo.COM_VACATION_ACCESS3(A.S_CR,A.S_S,A.EMPLID,@UserID,11,getdate())=1
			or 
		
		 dbo.DEF_USERINGROUP4(@UserID,'MNGD', getdate()) = 1 /* Mangmend Directors - Фомин, Машкин*/ -- KB4360
			or
		 @UserID = 857 /* Щербаков */ -- KB4360
		--	or
        -- @UserID = 26052 /* DEV Ефимов, для тестов  */ 

		)
		and
		A.S_S = 1000140 /* NOT approved */
		
		and
		U.ID <> @UserID /*Do not send to yourself*/  
		
		and 
		A.VACATIONTYPE<>20 /*NOT sick leave*/
	order by Expanded desc, DepartmentName asc

	return
END

--select * from @t
GO
GRANT SELECT
    ON OBJECT::[dbo].[COM_VACATION_REQUESTS_APPROVAL_REQUIRED] TO [EMEA\DEXHZ]
    AS [dbo];

