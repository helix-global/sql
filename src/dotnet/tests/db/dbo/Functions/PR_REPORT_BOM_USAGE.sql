
CREATE FUNCTION [dbo].[PR_REPORT_BOM_USAGE]
(
	@deviceSN nvarchar(50), @modelTypeId int, @UserID int
)
RETURNS 
	@ret table (SN nvarchar(50)
				, NAME nvarchar(200)
				, CODE nvarchar(16)
				, PARTQUANTITY decimal(20,10)
				, COMPLETED_DT datetime
				, MODELNAME nvarchar(200)
				, RESQUANTITY int
				, SUM_INSTALLED  decimal(20,10)
				, SUM_NOTINSTALLED decimal(20,10)
				, ID int
				, INSTALLUSERID int)
AS
BEGIN
	insert into @ret
	select D.SN
			, M.NAME
			, M.CODE
			, B.PARTQUANTITY
			, O.COMPLETED_DT
			, M1.NAME
			, D1.RESQUANTITY
			, SUM(B.PARTQUANTITY) over()
			, D1.RESQUANTITY - SUM(B.PARTQUANTITY) over()
			, D.ID
			, coalesce(KK.S_MR,KK.S_CR,O.S_MR) as INSTALLUSERID
		from PR_DEVICE_BOM B with(nolock)
			join PR_DEVICE D with(nolock) on B.DEVICEID=D.ID
			join PR_MODELS M with(nolock) on D.MODELID=M.ID
			join PR_DEVICE D1 with(nolock) on B.PARTID=D1.ID
			join PR_MODELS M1 with(nolock) on D1.MODELID=M1.ID
			join PR_OPERATION O with(nolock) on B.OPERATIONID=O.ID
			left join PR_OPERATION_INSTALL KK with(nolock) on KK.ID = B.ID
		where D1.SN=@deviceSN 
		  and D1.MODELID in (select ID from dbo.PR_VIEWMODEL_TAB(@UserID, getdate()))
		  and M1.TYPEID=@modelTypeId
		order by D.SN
		
	
	RETURN 
END