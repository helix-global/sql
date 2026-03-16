


CREATE FUNCTION [dbo].[COM_EMPLOYEE_VACATIONS_BY_DATE]
(
    @employeeId int, @DBEG date, @DEND date, @LangCode varchar(2)
)
RETURNS @ret table (ID int, EMPLID int, DBEG date, DEND date, VACATION_DAYS int, VACATION_DURATION decimal(10,2), VACATION_DURATION_TOTAL decimal(10,2), PERIODTYPE int, PERIODTYPE_NAME nvarchar(50), VACATIONTYPE int, VACATIONTYPE_NAME nvarchar(50))
AS
BEGIN


/* for KB4263 - list all "VACATIONS" for period in DAYS 
   Create: 06.09.2023 Efimov 
   Edit:
*/

/* test */
--declare @employeeId int = 1890 --Dmitrii Aleksandrov
--declare @DBEG date = '20230814'
--declare @DEND date = '20230818'
--declare @ret table (ID int, EMPLID int, DBEG date, DEND date, VACATION_DAYS int, VACATION_DURATION decimal(10,2), VACATION_DURATION_TOTAL decimal(10,2), PERIODTYPE int, PERIODTYPE_NAME nvarchar(50), VACATIONTYPE int, VACATIONTYPE_NAME nvarchar(50))
/* test */


/* for KB4263 - list all Not canceled Vactions except "Short Absence" for period in DAYS*/

-- types
--10	Vacation[L=com_enum_vacation
--20	Sick Leave[L=com_enum_sick_leave
--30	Short Absence[L=com_enum_sh_abs
--15	Unpaid Leave[L=com_enum_unpaid_leave
--50	Business Trip[L=com_enum_abs_businesstrip
--60	Training[L=com_enum_abs_training
--70	Special Leave[L=com_enum_abs_specialleave
--80	Internal Appointment[L=com_enum_abs_intapp
--90	Parental Leave[L=com_enum_abs_pl
--100	Child Care[L=com_enum_abs_childcare

insert into @ret
select 
	V.ID,
	V.EMPLID,
	V.DBEG,
	isnull(V.DEND,V.DBEG) DEND,
	DATEDIFF(day,V.DBEG,isnull(V.DEND,V.DBEG)) + 1 VACTIONDATES,
	case when isnull(V.PERIODTYPE,1) = 1 then 1 else 0.5 end as VACATIONDURATIONDAYS,
	(DATEDIFF(day,V.DBEG,isnull(V.DEND,V.DBEG)) + 1) * (case when isnull(V.PERIODTYPE,1) = 1 then 1 else 0.5 end) as VACATIONDURATIONDAYS_SUM,
	
	--case when isnull(VC.S_S,0) in (1000160, 2130053) then 1 else 0 end ISCANCELED,
	
	
	V.PERIODTYPE,
	--VP.CODE VACATION_PERIOD_CODE,
	
	dbo.COM_LANG_EN(VP.NAME) PERIOD_TYPE_NAME,
 
	V.VACATIONTYPE,
	--VT.CODE VACATION_TYPE_CODE,
	--dbo.COM_LANG_EN(VT.NAME) VACATION_TYPE_NAME
	dbo.COM_LANG_X(VT.NAME,@LangCode)


	--,V.*
from 
	COM_VACATION V with(nolock)
	left join COM_VACATION_CANCEL VC with(nolock) on VC.VACATIONID = V.ID
	left join (select CODE,NAME from DEF_ENUMERATION_T where ENUMOID = 1000120) VP on VP.CODE = V.PERIODTYPE
	left join (select CODE,NAME from DEF_ENUMERATION_T where ENUMOID = 1000119) VT on VT.CODE = V.VACATIONTYPE
where 
	V.EMPLID = @employeeId
	and
	(V.DBEG >=@DBEG and isnull(V.DEND, V.DBEG) <=@DEND) -- dates
	and
	V.VACATIONTYPE not in (30,80) -- not "Short Absence" and not "Internal Appointment"
	and 
	V.S_S in (1000141,2130051) /* approved or Submitted to HR */ 
	and 
	isnull(VC.S_S,0) not in (1000160, 2130053) /* cancelation is not "Approved" and not "Submitted to HR" */


	return


END