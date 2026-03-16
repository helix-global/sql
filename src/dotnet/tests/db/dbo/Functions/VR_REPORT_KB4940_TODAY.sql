CREATE function [dbo].[VR_REPORT_KB4940_TODAY](@now date, @mode int)
returns @res table (ID int, LINK nvarchar(max), COMPANY nvarchar(max), VISITOR_TYPE nvarchar(max), VISITOR_SUBTYPE nvarchar(max),VISIT_PERIOD nvarchar(max), DEPARTMENT nvarchar(max), VISITOR_NAMES nvarchar(max), ADATE date, DDATE date) as 
begin
	/* KB4940 Visitor Today - Customers */
	/* 12.09.2024 EFIMOV */
	/* Fix ENUM translate to English  09.12.2024 */

	/* 
	MODE
	1 = Customers
	2 = IPG Subsidiaries
	3 = Other
	*/
	
	declare @approved int = 5130013
	declare @mdpending int = 5130012

	if(@mode = 1)
	begin
		/* Customers - Existing, Potential*/
		insert into @res
		select 
			R.ID, 
			'a2l:\\Link=doc.vr_request.' + CONVERT(nvarchar(10), R.ID) as LINK,
			isnull(dbo.VR_GET_ALL_COMPANIES(R.ID),'[not specified]') as COMPANY,
			isnull(dbo.COM_LANG_EN(VISITORTYPE.NAME),'') VISITOR_TYPE,
			isnull(dbo.COM_LANG_EN(SUBTYPE.NAME), '') VISITOR_SUBTYPE,
			dbo.COM_FORMAT_DATETIME(R.ADATE,1) + ' - ' + dbo.COM_FORMAT_DATETIME(R.DDATE,1) VISIT_PERIOD,
			--D.NAME + ' (' + D.CODE + ')' DEPARTMENT,
			D.CODE DEPARTMENT,
			(select dbo.GROUP_CONCAT(convert(nvarchar(max),VISISTOR_NAME) + isnull(' (' + JOB_TITLE + ')','')) from VR_REQUEST_VISITORS where VNESHID = R.ID) VISITOR_NAMES,
			ADATE,
			DDATE

		from 
			VR_REQUEST R with (nolock)
			left join DEF_ENUMERATION_T VISITORTYPE with (nolock) on VISITORTYPE.ENUMOID = 2130051 and VISITORTYPE.CODE = R.VISITORTYPE
			left join DEF_ENUMERATION_T SUBTYPE with (nolock) on SUBTYPE.ENUMOID = 5130005 and SUBTYPE.CODE = R.VISITORSUBTYPE
			left join COM_DEPARTMENTS D with (nolock) on D.ID = R.DEPID
		where 
			(R.S_S = @approved or R.S_S = case when @now is null then @mdpending else @approved end)
			and
			R.VISITORSUBTYPE in (10, 20)
			and
			(@now is null or (@now between convert(date,ADATE) and convert(date,R.DDATE)))
	end
	else if (@mode = 2)
	begin
		/* IPG Subsidiaries */
		insert into @res
		select 
			R.ID, 
			'a2l:\\Link=doc.vr_request.' + CONVERT(nvarchar(10), R.ID) as LINK,
			isnull(dbo.VR_GET_ALL_COMPANIES(R.ID),'[not specified]') as COMPANY,
			isnull(dbo.COM_LANG_EN(VISITORTYPE.NAME), '') VISITOR_TYPE,
			ISNULL(dbo.COM_LANG_EN(SUBTYPE.NAME),'') VISITOR_SUBTYPE,
			dbo.COM_FORMAT_DATETIME(R.ADATE,1) + ' - ' + dbo.COM_FORMAT_DATETIME(R.DDATE,1) VISIT_PERIOD,
			--D.NAME + ' (' + D.CODE + ')' DEPARTMENT,
			D.CODE DEPARTMENT,
			(select dbo.GROUP_CONCAT(convert(nvarchar(max),VISISTOR_NAME) + isnull(' (' + JOB_TITLE + ')','')) from VR_REQUEST_VISITORS where VNESHID = R.ID) VISITOR_NAMES,
			ADATE,
			DDATE
		
		from 
			VR_REQUEST R with (nolock)
			left join DEF_ENUMERATION_T VISITORTYPE with (nolock) on VISITORTYPE.ENUMOID = 2130051 and VISITORTYPE.CODE = R.VISITORTYPE
			left join DEF_ENUMERATION_T SUBTYPE with (nolock) on SUBTYPE.ENUMOID = 5130005 and SUBTYPE.CODE = R.VISITORSUBTYPE
			left join COM_DEPARTMENTS D with (nolock) on D.ID = R.DEPID
		where 
			(R.S_S = @approved or R.S_S = case when @now is null then @mdpending else @approved end)
			and
			R.VISITORTYPE = 20 /* IPG Subsidiaries */
			and
			(@now is null or (@now between convert(date,ADATE) and convert(date,R.DDATE)))
	end
	else
	begin
		/* Other */
		insert into @res
		select 
			R.ID, 
			'a2l:\\Link=doc.vr_request.' + CONVERT(nvarchar(10), R.ID) as LINK,
			isnull(dbo.VR_GET_ALL_COMPANIES(R.ID),'[not specified]') as COMPANY,
			isnull(dbo.COM_LANG_EN(VISITORTYPE.NAME), '') VISITOR_TYPE,
			ISNULL(dbo.COM_LANG_EN(SUBTYPE.NAME),'') VISITOR_SUBTYPE,
			dbo.COM_FORMAT_DATETIME(R.ADATE,1) + ' - ' + dbo.COM_FORMAT_DATETIME(R.DDATE,1) VISIT_PERIOD,
			--D.NAME + ' (' + D.CODE + ')' DEPARTMENT,
			D.CODE DEPARTMENT,

			(select dbo.GROUP_CONCAT(convert(nvarchar(max),VISISTOR_NAME) + isnull(' (' + JOB_TITLE + ')','')) from VR_REQUEST_VISITORS where VNESHID = R.ID) VISITOR_NAMES,
			ADATE,
			DDATE
		
		from 
			VR_REQUEST R with (nolock)
			left join DEF_ENUMERATION_T VISITORTYPE with (nolock) on VISITORTYPE.ENUMOID = 2130051 and VISITORTYPE.CODE = R.VISITORTYPE
			left join DEF_ENUMERATION_T SUBTYPE with (nolock) on SUBTYPE.ENUMOID = 5130005 and SUBTYPE.CODE = R.VISITORSUBTYPE
			left join COM_DEPARTMENTS D with (nolock) on D.ID = R.DEPID
		where 
			(R.S_S = @approved or R.S_S = case when @now is null then @mdpending else @approved end)
			and
			isnull(R.VISITORTYPE,0) <> 20 /* visitor type != "IPG Subsidiaries" */
			and
			isnull(R.VISITORSUBTYPE,0) not in (10, 20) /* visitor not in "Existing", "Potential" */
			and
			(@now is null or (@now between convert(date,ADATE) and convert(date,R.DDATE)))
	end


  return

end