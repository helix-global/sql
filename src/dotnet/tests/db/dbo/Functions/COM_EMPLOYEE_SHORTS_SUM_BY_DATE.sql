

CREATE FUNCTION [dbo].[COM_EMPLOYEE_SHORTS_SUM_BY_DATE]
(
    @employeeId int, @DBEG date, @DEND date
)
RETURNS  int
AS
BEGIN


/* for KB4263 - list all "Short Absence" for period in MINUTES 
   Create: 06.09.2023 Efimov 
   Edit:
*/


/* test */
--declare @employeeId int = 28 -- 1761  --28  --35
--declare @DBEG date = '20230814'
--declare @DEND date = '20230818'
/* test */




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

declare @ret int

select 
	@ret = sum(V.SHORTDURATION)
	--V.EMPLID,
	--V.DBEG,
	--isnull(V.DEND,V.DBEG) DEND,
	--V.SHORTDURATION
	
	

	--DATEDIFF(day,isnull(V.DEND,V.DBEG),V.DBEG) + 1 VACTIONDATES,
	--case when V.PERIODTYPE = 1 then 1 else 0.5 end as VACATIONDURATIONDAYS,
	--(DATEDIFF(day,isnull(V.DEND,V.DBEG),V.DBEG) + 1) * (case when V.PERIODTYPE = 1 then 1 else 0.5 end) as VACATIONDURATIONDAYS_SUM,
	
	--case when isnull(VC.S_S,0) in (1000160, 2130053) then 1 else 0 end ISCANCELED,
	
	
	--V.PERIODTYPE,
	--VP.CODE VACATION_PERIOD_CODE,
	--dbo.COM_LANG_EN(VP.NAME) PERIOD_TYPE_NAME,
 
	--V.VACATIONTYPE,
	--VT.CODE VACATION_TYPE_CODE,
	--dbo.COM_LANG_EN(VT.NAME) VACATION_TYPE_NAME


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
	V.VACATIONTYPE in (30) -- "Short Absence"
	and 
	V.S_S in (1000141,2130051) /* approved or Submitted to HR */ 
	and 
	isnull(VC.S_S,0) not in (1000160, 2130053) /* cancelation is not "Approved" and not "Submitted to HR" if present */


	return @ret

END