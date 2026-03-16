
/*
29.05.2015
Граматкин А.В.
Процедура обрабатывает значение унаследованного параметра. 
Если ActionId = 0 - просто копирует
Если ActionId = 1 - вычитает значение параметра дочернего изделия из значения параметра родительского и сохраняет новое значение параметра родительского изделия
Если ActionId = 2 - суммирует значения параметра родительского и дочернего изделий и сохраняет новое значение параметра родительского изделия
Если ActionId = 3 - очищает значения параметра родительского изделия
*/
CREATE PROCEDURE [dbo].[PR_INHERITED_PARAMS]
(
	@ParentDeviceId INT
		,@ChildDeviceId INT
		,@ParamId INT
		,@ActionId INT
		,@CurrentOperationId INT
		,@ServiceOperationId INT
		,@UserId INT
)
AS
BEGIN

DECLARE 
		@ChildParamValue SQL_VARIANT
		,@ParentParamValue SQL_VARIANT
		,@ParamKindCode INT

SELECT 
	@ParamKindCode = PRM.PARAMKIND
FROM PR_MODELTYPE_PARAMS PRM

SELECT
	@ParentParamValue = VALUE	
FROM PR_DEVICE_PARAMS
WHERE
	DEVICEID = @ParentDeviceId
AND
	PARAMID = @ParamId

IF @ParentParamValue IS NULL
	RETURN
			
SELECT
	@ChildParamValue = VALUE	
FROM PR_DEVICE_PARAMS
WHERE
	DEVICEID = @ChildDeviceId
AND
	PARAMID = @ParamId



IF @ActionId = 0 
BEGIN
	INSERT INTO [dbo].[PR_OPERATION_PARAMS]
			   ([GID]
			   ,[S_CR]
			   ,[S_CDT]
			   ,[S_MR]
			   ,[S_MDT]
			   ,[OPERID]
			   ,[PARAMID]
			   ,[PVALUE]
			   ,[PCOMMENT]
			   ,[CREATEFLAG])
		 VALUES
			   (NEWID()
			   ,@UserId
			   ,GETDATE()
			   ,@UserId
			   ,GETDATE()
			   ,@ServiceOperationId
			   ,@ParamId
			   ,@ParentParamValue
			   ,NULL
			   ,NULL)
END
ELSE IF @ActionId = 1 -- PARENT MINUS CHILD
BEGIN
	IF @ParamKindCode = 3 -- INTEGER
	BEGIN
		INSERT INTO [dbo].[PR_OPERATION_PARAMS]
			   ([GID]
			   ,[S_CR]
			   ,[S_CDT]
			   ,[S_MR]
			   ,[S_MDT]
			   ,[OPERID]
			   ,[PARAMID]
			   ,[PVALUE]
			   ,[PCOMMENT]
			   ,[CREATEFLAG])
		 VALUES
			   (NEWID()
			   ,@UserId
			   ,GETDATE()
			   ,@UserId
			   ,GETDATE()
			   ,@CurrentOperationId
			   ,@ParamId
			   ,ISNULL(CAST(@ParentParamValue AS INT), 0) - ISNULL(CAST(@ChildParamValue AS INT),0)
			   ,NULL
			   ,NULL)
	END
	ELSE IF @ParamKindCode = 4 -- FLOAT
	BEGIN
		INSERT INTO [dbo].[PR_OPERATION_PARAMS]
			   ([GID]
			   ,[S_CR]
			   ,[S_CDT]
			   ,[S_MR]
			   ,[S_MDT]
			   ,[OPERID]
			   ,[PARAMID]
			   ,[PVALUE]
			   ,[PCOMMENT]
			   ,[CREATEFLAG])
		 VALUES
			   (NEWID()
			   ,@UserId
			   ,GETDATE()
			   ,@UserId
			   ,GETDATE()
			   ,@CurrentOperationId
			   ,@ParamId
			   ,ISNULL(CAST(@ParentParamValue AS FLOAT),0) - ISNULL(CAST(@ChildParamValue AS FLOAT), 0)
			   ,NULL
			   ,NULL)
	END
END
ELSE IF @ActionId = 2 -- PARENT PLUS CHILD
BEGIN
	IF @ParamKindCode = 3 -- INTEGER
	BEGIN
		INSERT INTO [dbo].[PR_OPERATION_PARAMS]
			   ([GID]
			   ,[S_CR]
			   ,[S_CDT]
			   ,[S_MR]
			   ,[S_MDT]
			   ,[OPERID]
			   ,[PARAMID]
			   ,[PVALUE]
			   ,[PCOMMENT]
			   ,[CREATEFLAG])
		 VALUES
			   (NEWID()
			   ,@UserId
			   ,GETDATE()
			   ,@UserId
			   ,GETDATE()
			   ,@CurrentOperationId
			   ,@ParamId
			   ,ISNULL(CAST(@ParentParamValue AS INT), 0) + ISNULL(CAST(@ChildParamValue AS INT), 0)
			   ,NULL
			   ,NULL)
	END
	ELSE IF @ParamKindCode = 4 -- FLOAT
	BEGIN
		INSERT INTO [dbo].[PR_OPERATION_PARAMS]
			   ([GID]
			   ,[S_CR]
			   ,[S_CDT]
			   ,[S_MR]
			   ,[S_MDT]
			   ,[OPERID]
			   ,[PARAMID]
			   ,[PVALUE]
			   ,[PCOMMENT]
			   ,[CREATEFLAG])
		 VALUES
			   (NEWID()
			   ,@UserId
			   ,GETDATE()
			   ,@UserId
			   ,GETDATE()
			   ,@CurrentOperationId
			   ,@ParamId
			   ,ISNULL(CAST(@ParentParamValue AS FLOAT), 0) + ISNULL(CAST(@ChildParamValue AS FLOAT), 0)
			   ,NULL
			   ,NULL)
	END	
END
ELSE IF @ActionId = 3 -- CLEAR PARENT
BEGIN
	DELETE FROM [dbo].[PR_OPERATION_PARAMS]
	WHERE
		[OPERID] = @CurrentOperationId
	AND
		PARAMID = @ParamId

	--INSERT INTO [dbo].[PR_OPERATION_PARAMS]
	--		   ([GID]
	--		   ,[S_CR]
	--		   ,[S_CDT]
	--		   ,[S_MR]
	--		   ,[S_MDT]
	--		   ,[OPERID]
	--		   ,[PARAMID]
	--		   ,[PVALUE]
	--		   ,[PCOMMENT]
	--		   ,[CREATEFLAG])
	--	 VALUES
	--		   (NEWID()
	--		   ,@UserId
	--		   ,GETDATE()
	--		   ,@UserId
	--		   ,GETDATE()
	--		   ,@CurrentOperationId
	--		   ,@ParamId
	--		   ,NULL -- SET PARAMETER VALUE TO NULL
	--		   ,NULL
	--		   ,NULL)
END


END