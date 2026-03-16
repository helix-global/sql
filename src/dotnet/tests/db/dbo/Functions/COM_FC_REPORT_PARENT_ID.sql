

--select dbo.COM_FC_REPORT_PARENT_ID(719094)



CREATE FUNCTION dbo.COM_FC_REPORT_PARENT_ID(@ReportId int)
returns int as
begin

	/* KB4265 - Get topper Hierarchy parent FC_REPORT ID by passed */
	

	--DECLARE @ReportId int = 719094 -- test

	declare @ret int

	;WITH ReportsHierarchy
	AS
	(
		SELECT
		  r1.ID, r1.PARENTID, [LEVEL] = 0
		FROM
			FC_REPORT r1 with (nolock)
		WHERE
			(ID = @ReportId)
	
		UNION ALL
	
		SELECT
			r2.ID, r2.PARENTID, [LEVEL] + 1
		FROM
			FC_REPORT r2 with (nolock)
			INNER JOIN ReportsHierarchy ON r2.ID = ReportsHierarchy.PARENTID
	)
	SELECT 
		@ret = r3.ID
		--, r3.PARENTID, r3.[LEVEL]
	FROM
		ReportsHierarchy r3
	WHERE
		r3.[LEVEL] = (SELECT MAX([LEVEL]) FROM ReportsHierarchy)
	
	return @ret

end