-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[PR_SN_FOR_OPERATION_TEST_FAILURE]
(
 @models nvarchar(4000),
 @boms nvarchar(4000),
 @date1 datetime,
 @date2 datetime,
 @type int
)
RETURNS 
@ret TABLE (DEVICEID int, VAL nvarchar(4000), VAL_TYPE INT)
AS
BEGIN

insert into @ret (DEVICEID, VAL, VAL_TYPE)
SELECT
	t1.DEVICEID
	,STUFF(
			(SELECT ', ' + t2.SN
				FROM (select distinct D1.SN, F.DEVICEID,  case when F1.INT_EXT in (1,3) then 1 
									 when F1.INT_EXT in (2) then 2 
									 else 0 end as type
						from FC_REPORT F
							join PR_DEVICE D on F.DEVICEID=D.ID
							join FC_REPORT F1 on F.ID=F1.PARENTID
							join PR_DEVICE_BOM B on F1.DEVICEID=B.PARTID and D.ID=B.DEVICEID
							join PR_MODELTYPE_BOM T with (nolock) on B.BOMID=T.ID
							join PR_DEVICE D1 on F1.DEVICEID=D1.ID
						where cast(D.SHIPPED_DT as DATE) between @date1 and @date2 
								and D.MODELID in(select ID from dbo.COM_STR2TABLE_INT(@models))
								and F1.S_S=1000104
								and T.ID in (select ID from dbo.COM_STR2TABLE_INT(@boms))) t2
				WHERE t1.DEVICEID=t2.DEVICEID and t1.type=t2.type
				ORDER BY t2.SN
				FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,2, '') AS VAL
		, t1.type
		FROM (select distinct D1.SN, F.DEVICEID,  case when F1.INT_EXT in (1,3) then 1 
									 when F1.INT_EXT in (2) then 2 
									 else 0 end as type
						from FC_REPORT F
							join PR_DEVICE D on F.DEVICEID=D.ID
							join FC_REPORT F1 on F.ID=F1.PARENTID
							join PR_DEVICE_BOM B on F1.DEVICEID=B.PARTID and D.ID=B.DEVICEID
							join PR_MODELTYPE_BOM T with (nolock) on B.BOMID=T.ID
							join PR_DEVICE D1 on F1.DEVICEID=D1.ID
						where cast(D.SHIPPED_DT as DATE) between @date1 and @date2 
								and D.MODELID in(select ID from dbo.COM_STR2TABLE_INT(@models))
								and F1.S_S=1000104
								and T.ID in (select ID from dbo.COM_STR2TABLE_INT(@boms))) t1
	where t1.type=@type
	GROUP BY t1.DEVICEID, t1.type

	RETURN 
END