


CREATE VIEW [power_bi].[POWERBI_ITEM]
AS

SELECT 
	ISNULL(MD.[NAME], '') [Model],
	ISNULL(MD.[CODE], '') [Navision Code (PN)],
	CASE DEV.[S_S] 
		WHEN 1 THEN 'Created'
		WHEN 1000008 THEN 'In Production'
		WHEN 1000010 THEN 'Shipped'
		WHEN 1000011 THEN 'In Repair'
		WHEN 1000022 THEN 'Production Completed'
		WHEN 1000029 THEN 'Pending Production'
		WHEN 1000030 THEN 'Shipped*'
		WHEN 1000039 THEN 'Repair Completed'
		WHEN 1000057 THEN 'Prepared'
		WHEN 1000069 THEN 'Postponed'
		WHEN 1000077 THEN 'Installed'
		WHEN 1000078 THEN 'Failed'
		WHEN 1000080 THEN 'Repair Required'
		WHEN 1000081 THEN 'Uninstalled'
		WHEN 1000085 THEN 'Shipped After Repair'
		WHEN 1000086 THEN 'Install Canceled'
		WHEN 1000100 THEN 'Postponed'
		WHEN 1000101 THEN 'Canceled'
		WHEN 1000130 THEN 'Imported'
		WHEN 1000158 THEN 'Recycled'
		WHEN 2130086 THEN 'Waiting For Costs Approval'
	END [State],
	DEV.[SCOMPLETED_DT] [Last repair completed],
	ISNULL((select top 1 FS.NN from PR_PRORDER FS with (nolock) 
		where FS.ID in (select FST.ORDERID from PR_PRORDER_SERVICE FST with (nolock) where FST.DEVICEID = DEV.ID) order by FS.ID desc), '') [LASTSERVORDER],
	DEV.[SHIPPED_DT] [Shipped],
	DEV.[SN]

FROM [dbo].[PR_DEVICE] DEV WITH(NOLOCK)
INNER JOIN [dbo].[PR_MODELS] MD WITH(NOLOCK) ON MD.[ID] = DEV.[MODELID]
INNER JOIN [dbo].[PR_MODELTYPE] MT WITH(NOLOCK) ON MT.[ID] = MD.[TYPEID] AND MT.[ENDLEV] = 1
GO
GRANT SELECT
    ON OBJECT::[power_bi].[POWERBI_ITEM] TO [EMEA\ltishina]
    AS [dbo];

