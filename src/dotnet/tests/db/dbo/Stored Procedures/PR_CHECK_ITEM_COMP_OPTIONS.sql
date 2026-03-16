CREATE procedure [dbo].[PR_CHECK_ITEM_COMP_OPTIONS] 
    @DeviceID int, @aUserID int 
as 

set nocount on

declare @errMess nvarchar(max)
DECLARE 
             @OPTION_ID INT
             ,@OPTION NVARCHAR(200)
             ,@TAG NVARCHAR(255)
             ,@OPTION_BLOCKING NVARCHAR(200)
             ,@MODEL_NAME NVARCHAR(200)
             ,@SN nvarchar(50)

DECLARE @DEVOPT TABLE (
                        DEVICEID INT
                        , MODELID INT
                        , MODEL_NAME NVARCHAR(200)
                        , OPTION_ID INT
                        , OPTION_NAME NVARCHAR(255)
                        , CMP_OUT NVARCHAR(200)
                        , CMP_REQ NVARCHAR(200)
                        , CMP_BLOCK NVARCHAR(200)
                        , PN NVARCHAR(200)
                        )

select @SN=SN
    from PR_DEVICE 
    where ID=@DeviceID

INSERT INTO @DEVOPT
SELECT 
       D.ID AS DEVICEID
        ,D.MODELID as MODELID
        ,M.NAME as MODEL_NAME
       ,MTOP.ID AS OPTION_ID
       ,MTOP.NAME AS OPTION_NAME
       ,MTOP.CMP_OUT AS CMP_OUT
       ,MTOP.CMP_REQ AS CMP_REQ
       ,MTOP.CMP_BLOCK as CMP_BLOCK
       ,MTOP.CODE as PN
FROM PR_DEVICE D
LEFT JOIN PR_DEVICE_OPT O ON D.ID = O.DEVICEID
             LEFT JOIN PR_MODELTYPE_OPTIONS MTOP ON O.OPTID = MTOP.ID
             left join PR_MODELS M on D.MODELID=M.ID
WHERE
       D.ID = @DeviceID

update @DEVOPT set CMP_OUT=S.CMP_OUT2
    from @DEVOPT O 
        join PR_MODEL_OPTIONS S on O.MODELID=S.MODELID and O.OPTION_ID=S.OPTIONID
    where S.CMP_OUT2_OVERRIDE=1

update @DEVOPT set CMP_REQ=S.CMP_REQ
    from @DEVOPT O 
        join PR_MODEL_OPTIONS S on O.MODELID=S.MODELID and O.OPTION_ID=S.OPTIONID
    where S.CMP_REQ_OVERRIDE=1

update @DEVOPT set CMP_BLOCK=S.CMP_BLOCK
    from @DEVOPT O 
        join PR_MODEL_OPTIONS S on O.MODELID=S.MODELID and O.OPTION_ID=S.OPTIONID
    where S.CMP_BLOCK_OVERRIDE=1
       
DECLARE REQ_OPTIONS CURSOR local read_only FOR 
SELECT DISTINCT
       REQ.OPTION_ID
       ,REQ.OPTION_NAME
       ,REQ.ITEM
       ,REQ.MODEL_NAME
FROM ( SELECT 
                    OPTION_ID
                    ,OPTION_NAME
                    ,RTRIM(LTRIM(ITEM)) AS ITEM 
                    ,MODELID
                    ,MODEL_NAME
             FROM @DEVOPT T
             CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_REQ)) REQ
LEFT JOIN(   SELECT 
                           OPTION_ID
                           ,OPTION_NAME
                           ,RTRIM(LTRIM(ITEM)) AS ITEM 
                            ,MODELID
                    FROM @DEVOPT T
                    CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_OUT)) AS USED ON REQ.ITEM = USED.ITEM and REQ.MODELID=USED.MODELID
WHERE
       USED.ITEM IS NULL 

OPEN REQ_OPTIONS
FETCH NEXT FROM REQ_OPTIONS INTO @OPTION_ID, @OPTION, @TAG,@MODEL_NAME
WHILE @@FETCH_STATUS = 0
BEGIN
    set @errMess = '#E' + @SN + ': Option "'+ @OPTION + '" of model "' + @MODEL_NAME + '" requires another Option with Output Compatibility Parameter "'+@TAG + '".'
    
    raiserror(@errMess, 16, 0) 
   
    FETCH NEXT FROM REQ_OPTIONS INTO @OPTION_ID, @OPTION, @TAG,@MODEL_NAME
END
CLOSE REQ_OPTIONS
DEALLOCATE REQ_OPTIONS



DECLARE BLOCK_OPTIONS CURSOR local read_only FOR 
SELECT DISTINCT
       BLCK.OPTION_ID
       ,BLCK.OPTION_NAME
       ,BLCK.ITEM
       ,USED.OPTION_NAME
       ,BLCK.MODEL_NAME
FROM ( SELECT 
                    OPTION_ID
                    ,OPTION_NAME
                    ,RTRIM(LTRIM(ITEM)) AS ITEM 
                    ,MODELID
                    ,MODEL_NAME
             FROM @DEVOPT T
             CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_BLOCK)) BLCK
 JOIN(   SELECT 
                           OPTION_ID
                           ,OPTION_NAME
                           ,RTRIM(LTRIM(ITEM)) AS ITEM 
                            ,MODELID
                    FROM @DEVOPT T
                    CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_OUT)) AS USED ON BLCK.ITEM = USED.ITEM and BLCK.MODELID=USED.MODELID


OPEN BLOCK_OPTIONS
FETCH NEXT FROM BLOCK_OPTIONS INTO @OPTION_ID, @OPTION, @TAG, @OPTION_BLOCKING,@MODEL_NAME
WHILE @@FETCH_STATUS = 0
BEGIN
    set @errMess = '#E' + @SN + ': Option "'+ @OPTION + '" of model "' + @MODEL_NAME + '" is not compatable with Option "' + @OPTION_BLOCKING + '" (Output Compatibility Parameter "'+@TAG + '").'
    
    raiserror(@errMess, 16, 0) 
   
    FETCH NEXT FROM BLOCK_OPTIONS INTO @OPTION_ID, @OPTION, @TAG, @OPTION_BLOCKING,@MODEL_NAME
END
CLOSE BLOCK_OPTIONS
DEALLOCATE BLOCK_OPTIONS


set nocount off