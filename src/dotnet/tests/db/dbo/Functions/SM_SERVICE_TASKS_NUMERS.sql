CREATE FUNCTION dbo.SM_SERVICE_TASKS_NUMERS
(
	@workOrderId int
)
RETURNS nvarchar(4000)
AS
BEGIN
	
	DECLARE @ret nvarchar(4000) = ''

	SELECT @ret = @ret + T.NAME  + char(13)+ char(10)
		from SM_WORKORDER_TASKS S
			join SM_SERVICETASKS T on S.TASKID=T.ID
		where S.VNESHID=@workOrderId

	RETURN @ret


	/*DECLARE @ret nvarchar(4000) = ''

	declare @t table (NAME nvarchar(200))

	insert into @t
		SELECT distinct T.NAME
			from SM_WORKORDER_TASKS S
				join SM_SERVICETASKS T on S.TASKID=T.ID
			where S.VNESHID=@workOrderId
			
	SELECT @ret = @ret + NAME + char(13) + char(10)
		from @t

	RETURN @ret*/
END