
CREATE VIEW [power_bi].[POWERBI_FAILUREREPORT]
AS
/*KB5414*/
SELECT					
	ISNULL(dbo.FC_REPORT_ANALYSISCODES_TXT(FR.ID,2), '') [Analysis Preview],
	FR.[USER4DT] [Approved],
	FR.[S_CDT] [Created],
	FR.[S_MDT] [Current day (when the data is updated)],
	CAST(FR.[USER1DT] AS DATE) [Date sent to repair],
	CAST(FR.[FAILUREDATE] AS DATE) [Failure Date],
	CASE ISNULL(FR.[INT_EXT], '')
		WHEN 1 THEN 'IPG Internal'
		WHEN 2 THEN 'External ("in field")'
		WHEN 3 THEN 'Assembly department'
		ELSE CAST(FR.[INT_EXT] AS VARCHAR(10))
	END [Failure Location],
	ISNULL(dbo.FC_REPORT_CODES_TXT(FR.ID,2), '') [Failure Preview],
	ISNULL(CUST.[NAME], '') [From Customer],
	ISNULL(DEP.[CODE], '') [From Department],
	(select cast(YY.S_CDT as date) from [dbo].[PR_DEVICE] YY with (nolock) where YY.ID = FR.[DEVICEID]) [Item Creation Date],
	ISNULL(M.[NAME], '') [Model],
	ISNULL(M.[CODE], '') [Model Code (PN)],
	ISNULL(FR.[OPERTIME], 0) [Operation Time, hrs],
	CAST(FR.[REPAIRDATE] AS DATE) [Repair/Analysis Date],
	FR.[ID] [ReportID],
	FR.[SN] [Serial Number],
	ISNULL(FR.[RMA], '') [Service Number],
	CASE WHEN FR.[RMA_TYPE] IS NULL THEN '' ELSE CASE FR.[RMA_TYPE]
		WHEN 1 THEN 'INT'
		WHEN 2 THEN 'RMA'
		WHEN 3 THEN 'SC'
		WHEN 4 THEN 'SCAFF'
		ELSE CAST(FR.[RMA_TYPE] AS VARCHAR(10))
	END END [Service Number Type],
	CASE FR.[S_S] 
		WHEN 1 THEN 'Created'
		WHEN 1000103 THEN 'Analyzed'
		WHEN 1000104 THEN 'Approved'
		WHEN 1000123 THEN 'Closed'
		WHEN 1000124 THEN 'Rejected'
		WHEN 2130020 THEN 'Requested'
		WHEN 2130021 THEN 'Generated'
		WHEN 2130022 THEN 'Issued'
		ELSE CAST(FR.[S_S] AS VARCHAR(10))
	END [State],
	CASE WHEN FR.[WARRANTY] IS NULL THEN '' ELSE CASE FR.[WARRANTY]
		WHEN 1 THEN 'YES'
		WHEN 0 THEN 'NO'
		ELSE CAST(FR.[WARRANTY] AS VARCHAR(10))
	END END [Warranty Item],
	CASE WHEN FR.[WARRANTYREPAIR] IS NULL THEN '' ELSE CASE FR.[WARRANTYREPAIR]
		WHEN 1 THEN 'YES'
		WHEN 0 THEN 'NO'
		ELSE ''
	END END	[Warranty Repair],
	(select cast(DD.COMPLETED_DT as date) from PR_DEVICE DD where DD.ID = FR.DEVICEID) [Date of production 1],
	CAST(FR.[DATE_PRODUCT3] AS DATE) [Date of production 3],
	CAST(FR.[USER3DT] AS DATE) [Date of receipt],
	ISNULL(FR.[RESULT_INC_INSP], '') [Results of Incoming Inspection],
	ISNULL(FR.[ACTIONPOINTS], '') [Action Points]

FROM [dbo].[FC_REPORT] FR WITH(NOLOCK) 
LEFT JOIN [dbo].[COM_CUSTOMER] CUST WITH(NOLOCK) ON CUST.[ID] = ISNULL(FR.[FROMCUSTOMERID], 0) 
LEFT JOIN [dbo].[COM_DEPARTMENTS] DEP WITH(NOLOCK) ON DEP.[ID] = ISNULL(FR.[FROMDEPID], 0)
LEFT JOIN [dbo].[PR_MODELS] M WITH(NOLOCK) ON M.[ID] = ISNULL(FR.[MODELID], 0)
GO
GRANT SELECT
    ON OBJECT::[power_bi].[POWERBI_FAILUREREPORT] TO [EMEA\ltishina]
    AS [dbo];

