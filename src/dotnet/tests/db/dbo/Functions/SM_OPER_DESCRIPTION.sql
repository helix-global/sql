CREATE FUNCTION [dbo].SM_OPER_DESCRIPTION(@OperID int, @mode int)
RETURNS nvarchar(max)
AS
BEGIN
	
	DECLARE @ret nvarchar(max) = 'List of changes which are done in '
	
	select @ret=@ret+isnull(B.SN,'NA')+char(13)+char(10)
	from PR_OPERATION A with(nolock)
	left join PR_DEVICE B with(nolock) on B.ID = A.DEVICEID
	where A.ID = @OperID
	
	declare @uninstall nvarchar(max) = ''
	
	select @uninstall = @uninstall+isnull(C.NAME,'NA')+'; '+isnull(D.NAME,'NA')+'; SN '+B.SN
	from PR_OPERATION_UNINSTALL A with(nolock)
	left join PR_OPERATION_INSTALL B with(nolock) on B.ID = A.INSTALLROWID
	left join PR_MODELTYPE_BOM C with(nolock) on C.ID = B.BOMID
	left join PR_MODELS D with(nolock) on D.ID = B.PARTMODELID
	left join PR_OPERATION OO with(nolock) on OO.ID = A.OPERID
	where A.OPERID = @OperID
	  and OO.COMPLETED_DT is not null
	
	
	if len(@uninstall) > 2
	  set @ret=@ret+'Remove'+char(13)+char(10)+@uninstall+char(13)+char(10)
	  
	  
	declare @install nvarchar(max) = ''  
	
    select @install = @install+isnull(C.NAME,'NA')+'; '+isnull(D.NAME,'NA')+'; SN '+A.SN
	from PR_OPERATION_INSTALL A with(nolock)
	left join PR_MODELTYPE_BOM C with(nolock) on C.ID = A.BOMID
	left join PR_MODELS D with(nolock) on D.ID = A.PARTMODELID
	left join PR_OPERATION OO with(nolock) on OO.ID = A.OPERID
	where A.OPERID = @OperID	
	  and OO.COMPLETED_DT is not null

	if len(@install) > 2
	  set @ret=@ret+'Install:'+char(13)+char(10)+@install+char(13)+char(10)
	

	RETURN @ret
END