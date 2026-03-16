CREATE FUNCTION [dbo].[COM_DEP_HEADS_VACATIONS]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
	select DISTINCT
	V.ID
	,V.S_CDT
	, [dbo].[COM_VACATION_PERIOD_STR1](V.ID,10) PERIODSTR
	 ,V.EMPLID
	 ,E.SURNAME + ' ' + E.GIVENNAME EMPLNAME
	 ,V.DBEG
	 ,ISNULL(V.DEND, V.DBEG) DEND
	 , V.VACATIONTYPE
	, V.S_S
	, T.VNESHID as PRODDEP  -- 1=Prod 2=No PROD
	, [dbo].[DEF_STATE_NAME_EN](V.S_S) S_S_NAME
	,V.PERIODTYPE
	, V.SHORTSTART
	,V.SHORTDURATION
	, VC.S_S as CANCELATION_S_S
	, VC.ID as CANCELATION_ID
	, [dbo].[DEF_ENUM_V_EN](VT.ENUMOID, VT.NAME, VT.CODE) VACATIONTYPENAME
from 
	COM_VACATION V with(nolock)
	join COM_DH_VP_SETTINGS_T T with(nolock) on V.EMPLID = T.EMPLID 
	left join COM_EMPLOYEE E with(nolock) on E.ID = V.EMPLID
	left join (select ENUMOID, [NAME], CODE from DEF_ENUMERATION_T with(nolock) where ENUMOID = 1000119 ) VT  on VT.CODE = V.VACATIONTYPE
	--только аппрувленные cancelation или переданные в HR
	left join (select * from COM_VACATION_CANCEL with(nolock) where S_S in (1000160,2130053)) VC on VC.VACATIONID = V.ID --Approved + SendToHR
	--left join COM_VACATION_CANCEL VC with(nolock) on VC.VACATIONID = V.ID --старый вариант

	

	where  
		VC.ID is null --у которых НЕТ зааппрувленных Cancelation
		--and V.DBEG >= GETDATE()
		--and  V.ID = 137506

	
	
	--order by V.DBEG
)