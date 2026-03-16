-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PR_OPER_TEST_FAILURE_REPORT]
 @modelIds nvarchar(4000),
 @bomIds nvarchar(4000),
 @date1 datetime,
 @date2 datetime
AS
BEGIN
	declare  @tDevices table (ID int, SN nvarchar(50), DEVICE_MODEL_NAME nvarchar(200), CUSTOMER_NAME nvarchar(100),
						EMISSION_TIME decimal(10,1), SHIPPED_DT date, ILA_COMMENTS nvarchar(max), EXT_COMMENTS nvarchar(max))

	insert into @tDevices (ID 
						, SN
						, DEVICE_MODEL_NAME
						, CUSTOMER_NAME
						, EMISSION_TIME
						, SHIPPED_DT
						, ILA_COMMENTS
						, EXT_COMMENTS
						)
	select D.ID
		, D.SN
		, M.NAME
		, C.NAME
		, REPLACE(CAST(dbo.PR_DEVICE_PARAM(D.ID, 39837) as nvarchar(100)),',','.')
		, CAST(D.SHIPPED_DT as DATE)
		, int_rep.VAL
		, ext_rep.VAL
	from PR_DEVICE D with (nolock)
		left join PR_MODELS M with (nolock) on D.MODELID=M.ID 
		left join PR_MODELTYPE T with (nolock) on M.TYPEID=T.ID 
		left join PR_PRORDER P with (nolock) on P.ID = D.LASTSRVORDID
		left join PR_SUPPLY S with (nolock) on S.ID = D.SORDERID
		left join PR_PRORDER P1 with (nolock) on P1.ID = D.ORDERID
		left join COM_CUSTOMER C with (nolock) on coalesce(P.CUSTOMERID,S.CUSTOMERID,P1.CUSTOMERID)=C.ID
		left join (select f.DEVICEID, f.VAL from dbo.PR_SN_FOR_OPERATION_TEST_FAILURE(@modelIds,@bomIds,@date1,@date2,1) f) int_rep on D.ID=int_rep.DEVICEID
		left join (select f.DEVICEID, f.VAL from dbo.PR_SN_FOR_OPERATION_TEST_FAILURE(@modelIds,@bomIds,@date1,@date2,2) f) ext_rep on D.ID=ext_rep.DEVICEID
	where cast(D.SHIPPED_DT as DATE)>=@date1 and cast(D.SHIPPED_DT as DATE)<=@date2
			 and D.MODELID in(select ID from dbo.COM_STR2TABLE_INT(@modelIds))

	declare @tResult table (ID int, FIELD nvarchar(200), SORT varchar(50))

	insert into @tResult (ID, FIELD, SORT)
	select D.ID, B.MODELNAME, 
		'  BOM Items' as SORT
	from @tDevices D 
		left join PR_DEVICE_BOM B on D.ID=B.DEVICEID
		left join PR_DEVICE DB on B.PARTID=DB.ID
		left join PR_MODELS MB on DB.MODELID=MB.ID
		left join PR_MODELTYPE_BOM MTB on B.BOMID=MTB.ID
	where MTB.ID in (select ID from dbo.COM_STR2TABLE_INT(@bomIds))
	--where MTB.NAME like 'Module%'
	UNION ALL
	select D.ID, FA.NAME, 
		' Internal Failures' as SORT
	from @tDevices D 
		left join FC_REPORT F1 on F1.DEVICEID=D.ID
		left join FC_REPORT F on F1.ID=F.PARENTID
		left join PR_DEVICE_BOM B on F.DEVICEID=B.PARTID and D.ID=B.DEVICEID
		left join PR_MODELTYPE_BOM MTB on B.BOMID=MTB.ID
		left join FC_REPORT_ANALYSIS_CODES FC on FC.VNESHID=F.ID
		left join FC_FAILUREANALYSISCODES FA on FC.ANALYSISCODEID=FA.ID
	where F.INT_EXT in(1,3)
		and MTB.ID in (select ID from dbo.COM_STR2TABLE_INT(@bomIds))
		and F.S_S = 1000104
		--and MTB.NAME like 'Module%'
		and FC.ID is not null
	UNION ALL
	select D.ID, FA.NAME, 
		'External Failures' as SORT
	from @tDevices D 
		left join FC_REPORT F1 on F1.DEVICEID=D.ID
		left join FC_REPORT F on F1.ID=F.PARENTID
		left join PR_DEVICE_BOM B on F.DEVICEID=B.PARTID and D.ID=B.DEVICEID
		left join PR_MODELTYPE_BOM MTB on B.BOMID=MTB.ID
		left join FC_REPORT_ANALYSIS_CODES FC on FC.VNESHID=F.ID
		left join FC_FAILUREANALYSISCODES FA on FC.ANALYSISCODEID=FA.ID
	where F.INT_EXT=2
		and MTB.ID in (select ID from dbo.COM_STR2TABLE_INT(@bomIds))
		and F.S_S = 1000104
		--and MTB.NAME like 'Module%'
		and FC.ID is not null

	declare @tResultGroupped table (ID int, FIELD nvarchar(200), SORT varchar(50), COUNT_ID int)

	insert into @tResultGroupped
	select D.ID, R.FIELD, 
		R.SORT, COUNT(D.ID) as COUNT_ID
	from @tDevices D
		join @tResult R on D.ID=R.ID
	group by D.ID, D.SN, D.DEVICE_MODEL_NAME, D.CUSTOMER_NAME, R.FIELD, 
		D.EMISSION_TIME, D.SHIPPED_DT, ILA_COMMENTS, EXT_COMMENTS, R.SORT 
	order by D.DEVICE_MODEL_NAME, SORT, FIELD

	select * from @tDevices
	select * from @tResultGroupped
	select SORT, FIELD
	from @tResultGroupped
	group by SORT, FIELD
	order by SORT DESC, FIELD DESC

END