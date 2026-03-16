CREATE PROCEDURE [dbo].[PR_INHERITED_PARAMS2]
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

SELECT @ParamKindCode = PRM.DATATYPE
FROM PR_MODELTYPE_PARAMS PRM
WHERE PRM.ID = @ParamId

SELECT @ParentParamValue = VALUE    
FROM PR_DEVICE_PARAMS
WHERE DEVICEID = @ParentDeviceId
  AND PARAMID = @ParamId

IF @ParentParamValue IS NULL
  RETURN
            
SELECT @ChildParamValue = VALUE 
FROM PR_DEVICE_PARAMS
WHERE DEVICEID = @ChildDeviceId
  AND PARAMID = @ParamId


IF @ActionId = 0 
BEGIN
    INSERT INTO PR_OPERATION_PARAMS(GID,S_CR,S_CDT,S_MR,S_MDT,OPERID,PARAMID,PVALUE,PCOMMENT,CREATEFLAG)
    VALUES (NEWID(),@UserId,GETDATE(),@UserId,GETDATE(),@ServiceOperationId,@ParamId,@ParentParamValue,NULL,NULL)

    declare @fileId int --13.03.2021 ashchukin
    select @fileId=max(F.ID)
        from PR_OPERATION_FILES F
            join PR_OPERATION O on F.OPERATIONID=O.ID
        where O.DEVICEID=@ParentDeviceId and PARAMID=@ParamId 

	if @fileId is not null
		insert into PR_OPERATION_FILES (GID, S_CR, S_CDT, OPERATIONID, FILENAME, FILESIZE, FILEDATE, FILEBLOB, FILEDESC, FILEPREVIEW, PARAMID)
		select NEWID(), @UserId, GETDATE(), @ServiceOperationId, FILENAME, FILESIZE, FILEDATE, FILEBLOB, FILEDESC, FILEPREVIEW, PARAMID
		from PR_OPERATION_FILES
		where ID=@fileId -- OPERATIONID=@CurrentOperationId and PARAMID=@ParamId
    
END
ELSE IF @ActionId = 1 -- PARENT MINUS CHILD
BEGIN
    IF @ParamKindCode = 3 -- INTEGER
    BEGIN
       update PR_OPERATION_PARAMS 
          set PVALUE = ISNULL(CAST(@ParentParamValue AS INT), 0) - ISNULL(CAST(@ChildParamValue AS INT),0) 
        where OPERID = @CurrentOperationId
          and PARAMID = @ParamId
    END
    ELSE IF @ParamKindCode = 4 -- FLOAT
    BEGIN
       update PR_OPERATION_PARAMS 
          set PVALUE = ISNULL(CAST(@ParentParamValue AS FLOAT),0) - ISNULL(CAST(@ChildParamValue AS FLOAT), 0) 
        where OPERID = @CurrentOperationId
          and PARAMID = @ParamId
    END
END
ELSE IF @ActionId = 2 -- PARENT PLUS CHILD
BEGIN
    IF @ParamKindCode = 3 -- INTEGER
    BEGIN
       update PR_OPERATION_PARAMS 
          set PVALUE = ISNULL(CAST(@ParentParamValue AS INT), 0) + ISNULL(CAST(@ChildParamValue AS INT),0) 
        where OPERID = @CurrentOperationId
          and PARAMID = @ParamId
    END
    ELSE IF @ParamKindCode = 4 -- FLOAT
    BEGIN
       update PR_OPERATION_PARAMS 
          set PVALUE = ISNULL(CAST(@ParentParamValue AS FLOAT),0) - ISNULL(CAST(@ChildParamValue AS FLOAT), 0) 
        where OPERID = @CurrentOperationId
          and PARAMID = @ParamId
    END 
END
ELSE IF @ActionId = 3 -- CLEAR PARENT
BEGIN
    DELETE FROM PR_OPERATION_PARAMS
    WHERE OPERID = @CurrentOperationId
      AND PARAMID = @ParamId
END


END