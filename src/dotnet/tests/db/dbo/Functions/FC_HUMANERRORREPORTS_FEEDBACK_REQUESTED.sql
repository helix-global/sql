CREATE function [dbo].[FC_HUMANERRORREPORTS_FEEDBACK_REQUESTED] ()
/* KB5152 Get All Humen Error Report in "Feedback requested" status */
/* 20.03.2025 - Efimov */
returns @res table (
	HER_ID int, 
	HER_CREATED_DT datetime,
	HER_MODIFIED_DT datetime,
	HER_LAST_MSG_DT datetime,
	EMPL_ID int, 
	EMPL_NAME nvarchar(max),
	DEP_ID int, 
	DEP_CODE nvarchar(max), 
	DEP_NAME nvarchar(max), 
	FAR_ID int, 
	OPERATION_ID int, 
	OPERATION_NAME nvarchar(max),
	CREATED_DAYS_AGO int
	)

as 
begin

	insert into @res
	select 
		HER.ID HER_ID, 
		HER.S_CDT HER_CREATED_DT,
		HER.S_MDT HER_MODIFIED_DT,
		HER.LAST_OPER_FEEDBACK_MSG_DT HER_LAST_MSG_DT,
		HER.EMPLID EMPL_ID, 
		E.NAME EMPL_NAME,
		D.ID DEP_ID, D.CODE DEP_CODE, D.NAME DEP_NAME,
		FAR.ID FAR_ID, 
		FAR.OPERFAILED OPERATION_ID, 
		O.NAME OPERATION_NAME,
		DATEDIFF(day,HER.S_CDT, GETDATE()) CREATED_DAYS_AGO
	from 
		dbo.FC_HUMANERROR HER with (nolock)
		left join dbo.FC_REPORT FAR with (nolock) on FAR.ID = HER.REPORTID
		left join PR_OPERATION OPER with (nolock) on FAR.OPERFAILED = OPER.ID
		left join PR_OPERATIONS O with (nolock) on O.ID = OPER.OPERTYPEID
		left join dbo.COM_EMPLOYEE E with (nolock) on E.ID = HER.EMPLID
		left join dbo.COM_DEPARTMENTS D with (nolock) on D.ID = HER.DEPID
	where 
		HER.S_S = 5290001 /* Feedback requested */
	order by HER.S_CDT
  
	return
  
end