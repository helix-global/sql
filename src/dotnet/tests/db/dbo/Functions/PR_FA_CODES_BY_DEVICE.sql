-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[PR_FA_CODES_BY_DEVICE]
(
	@deviceId int, @mode int, @bomIds nvarchar(4000)
)
RETURNS nvarchar(4000)
AS
BEGIN
	
	declare @ret nvarchar(4000) = ''
	declare @boms table (ID int)

	insert into @boms
	select ID from dbo.COM_STR2TABLE_INT(@bomIds)		

	if @mode=1 --internal FAR
	begin
		select @ret=@ret + D.SN + ','
			from PR_DEVICE_BOM B with (nolock)
				left join PR_DEVICE D with (nolock) on B.PARTID=D.ID
				left join PR_MODELS M with (nolock) on D.MODELID=M.ID
				left join PR_MODELTYPE_BOM T with (nolock) on B.BOMID=T.ID
				left join FC_REPORT R  with (nolock)on B.PARTID=R.DEVICEID
				--left join FC_REPORT_ANALYSIS_CODES A with (nolock) on R.ID=A.VNESHID
			where --T.NAME like 'Module%' 
					T.ID in (select ID from @boms)
					and B.DEVICEID=@deviceId
					and R.INT_EXT in (1,3)
			GROUP BY D.SN
	end

	if @mode=2 --external FAR
	begin
		select @ret=@ret + D.SN + ','
			from PR_DEVICE_BOM B with (nolock)
				left join PR_DEVICE D with (nolock) on B.PARTID=D.ID
				left join PR_MODELS M with (nolock) on D.MODELID=M.ID
				left join PR_MODELTYPE_BOM T with (nolock) on B.BOMID=T.ID
				left join FC_REPORT R with (nolock) on B.PARTID=R.DEVICEID
				--left join FC_REPORT_ANALYSIS_CODES A with (nolock) on R.ID=A.VNESHID
			where --T.NAME like 'Module%' 
					T.ID in (select ID from @boms)
					and B.DEVICEID=@deviceId
					and R.INT_EXT in (2)
			GROUP BY D.SN
	end

	if @ret<>''
		set @ret = SUBSTRING(@ret,1,len(@ret)-1)

	return @ret

END