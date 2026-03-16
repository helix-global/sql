

CREATE FUNCTION [dbo].[VR_GET_ALL_COMPANIES]
(
	@RequestID int
)
RETURNS nvarchar(100)
AS
BEGIN
  
	/* KB 4905 */

	declare @companies table (COMPANY nvarchar(1000))
	
	--insert from vr_request
	insert into @companies (COMPANY)
	select TOP 1 
		VR_R.COMPANY
	from VR_REQUEST VR_R with(nolock)
	where VR_R.ID = @RequestID
	and VR_R.COMPANY is not null
	
	--insert from vr_request_visitors
	insert into @companies (COMPANY)
	select
		DISTINCT convert(nvarchar(1000),VR_V.COMPANY) as COMPANY
	from VR_REQUEST_VISITORS VR_V with (nolock)
	where VR_V.VNESHID = @RequestID
	and VR_V.COMPANY is not null
	
	--insert from vr_request_visitors
	insert into @companies (COMPANY)
	select
		DISTINCT convert(nvarchar(1000),VR_V.EXT_COMPANY_NAME) as COMPANY
	from VR_REQUEST_VISITORS VR_V with (nolock)
	where VR_V.VNESHID = @RequestID
	and VR_V.EXT_COMPANY_NAME is not null
	
	--insert from vr_request_visitors
	insert into @companies (COMPANY)
	select
	DISTINCT convert(nvarchar(1000),VR_V.BRANCH_COUNTRY) as COMPANY
	from VR_REQUEST_VISITORS VR_V with (nolock)
	where VR_V.VNESHID = @RequestID
	and VR_V.BRANCH_COUNTRY is not null
	
	
	return (select dbo.GROUP_CONCAT(DISTINCT COMPANY) from @companies)

END