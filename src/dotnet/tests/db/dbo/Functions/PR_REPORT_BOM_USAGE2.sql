CREATE FUNCTION [dbo].[PR_REPORT_BOM_USAGE2](@deviceSN nvarchar(50), @modelTypeId int, @UserID int, @mode int)
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
	/* 
	KB2223 @mode=1 - добавляются отмененные операции с пустым COMPLETED_DT
	*/

	insert into @ret(SN, NAME, CODE, PARTQUANTITY, COMPLETED_DT, MODELNAME, ID, INSTALLUSERID, RESQUANTITY)
	select D.SN
			, M.NAME
			, M.CODE
			, B.PARTQUANTITY
			, O.COMPLETED_DT
			, M1.NAME
			, D.ID
			, coalesce(KK.S_MR,KK.S_CR,O.S_MR) as INSTALLUSERID
			, D1.RESQUANTITY
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


	  if @mode=1
	  begin

		insert into @ret(SN, NAME, CODE, PARTQUANTITY, MODELNAME, ID, RESQUANTITY)
		select D.SN
				, M.NAME
				, M.CODE
				, KK.PARTQUANTITY
				, M1.NAME
				, D.ID
				, D1.RESQUANTITY
			from PR_OPERATION_INSTALL KK with(nolock)
			left join PR_OPERATION O with(nolock) on O.ID = KK.OPERID
			left join PR_DEVICE D1 with(nolock) on D1.ID = KK.PARTID
			left join PR_MODELS M1 with(nolock) on M1.ID = D1.MODELID
			left join PR_DEVICE D with (nolock) on D.ID = O.DEVICEID
			left join PR_MODELS M with(nolock) on M.ID = D.MODELID
			where O.S_S = 1000023/*canceled*/ 
			  and D1.SN = @deviceSN 
			  and D1.MODELID in (select ID from dbo.PR_VIEWMODEL_TAB(@UserID, getdate()))
			  and M1.TYPEID = @modelTypeId
	        
	  end
		
	  update @ret set SUM_INSTALLED = (select sum(PARTQUANTITY) from @ret)
	  update @ret set SUM_NOTINSTALLED = RESQUANTITY - SUM_INSTALLED
	  update @ret set SUM_NOTINSTALLED = 0 where SUM_NOTINSTALLED < 0
		
	  RETURN 
	  
END