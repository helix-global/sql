-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[COM_EMPLOYEE_SKILL_LAST_DATES_BY_DATE]
( @depId int, @dateActual datetime)
RETURNS TABLE 
AS
RETURN 
(
	select U.EMPLID as EMPLOYEEID, T.USERID, ISNULL(OS.SKILLID, OG.SKILLID) as SKILLID, MAX(T.DEND) as LAST_DATE
		from PR_OPERATION_TIME T with (nolock)
			join PR_OPERATION O with (nolock) on T.OPERID=O.ID
			join (select U.ID as USERID, MIN(ISNULL(P.DBEG,E.S_CDT)) as FDATE,E.DEPID, E.ID as EMPLID
					from DEF_USERS U
						left join COM_EMPLOYEE E on U.EMPLOYEEID=E.ID
						left join COM_EMPL_PERIODS P on E.ID=P.EMPLID
						where ISNULL(P.DBEG,E.S_CDT) is not null and E.S_S<>1000092 and E.DEPID in(select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@depId,1))
					group by U.ID,E.DEPID, E.ID) U on T.USERID=U.USERID
			left join COM_OPERATION_SKILL OS with (nolock) on O.OPERTYPEID=OS.OPERFORM_ID
			join PR_OPERATIONS OP with (nolock) on O.OPERTYPEID=OP.ID
			left join COM_OPERATION_GROUP_SKILL OG with (nolock) on OP.OPERGRID=OG.OPERGROUP_ID
		where (OS.SKILLID is not null or OG.SKILLID is not null)
				and T.S_CDT<=@dateActual and T.S_CDT>=U.FDATE and O.S_S=1000013
		group by T.USERID, ISNULL(OS.SKILLID, OG.SKILLID), U.EMPLID
		
)