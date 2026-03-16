CREATE function [dbo].[COM_GET_MD_EMPLID](@aDEPID int)
returns int as 
begin
	/* KB4831 */
	return
	   (select TOP 1 DHS.DEFAULT4EMPLID EMPLID 
		from COM_DH_VP_SETTINGS DHS 
		left join COM_DH_VP_SETTINGS_T DHST on DHST.VNESHID = DHS.ID
		join COM_EMPLOYEE E on E.ID = DHST.EMPLID
	where 
		E.DEPID = @aDEPID 
		and 
		ROLEINDEP = 100
	   )
end



--select dbo.[COM_GET_MD_USER](348)

--select * from COM_EMPLOYEE where ROLEINDEP = 100