CREATE procedure [dbo].[PR_CHECK_ORDER_COMP_OPTIONS] @ContextID int, @aUserID int 
as 

set nocount on

DECLARE 
             @OPTION_ID INT
             ,@OPTION NVARCHAR(200)
             ,@TAG NVARCHAR(255)
             ,@OPTION_BLOCKING NVARCHAR(200)
			 ,@MODEL_NAME NVARCHAR(200)

declare @BlockIncosistent int
declare @errMess nvarchar(max)

select @BlockIncosistent = isnull(B.BLOCKBYCOMPATIPRMS,0) 
from PR_PRORDER A with (nolock)
left join COM_DEPARTMENTS B with (nolock) on B.ID = A.DEPARTMENTID
where A.ID =  @ContextID


DECLARE @ORDEROPT TABLE (
						ORDER_ID INT
						, MODELID INT
						, MODEL_NAME NVARCHAR(200)
						, OPTION_ID INT
						, OPTION_NAME NVARCHAR(255)
						, CMP_OUT NVARCHAR(200)
						, CMP_REQ NVARCHAR(200)
						, CMP_BLOCK NVARCHAR(200)
						, PN NVARCHAR(200)
						)

INSERT INTO @ORDEROPT
SELECT 
       ORD.ID AS ORDER_ID
		,ORDT.MODELID as MODELID
		,M.NAME as MODEL_NAME
       ,MTOP.ID AS OPTION_ID
       ,MTOP.NAME AS OPTION_NAME
       ,MTOP.CMP_OUT AS CMP_OUT
       ,MTOP.CMP_REQ AS CMP_REQ
	   ,MTOP.CMP_BLOCK as CMP_BLOCK
	   ,MTOP.CODE as PN
FROM PR_PRORDER ORD
LEFT JOIN PR_PRORDER_T ORDT ON ORD.ID = ORDT.PRORDERID
       LEFT JOIN PR_PRORDER_TO ORDOP ON  ORDT.ID = ORDOP.OPID
             LEFT JOIN PR_MODELTYPE_OPTIONS MTOP ON ORDOP.OPTID = MTOP.ID
			 left join PR_MODELS M on ORDT.MODELID=M.ID
WHERE
       ORD.ID = @ContextID

update @ORDEROPT set CMP_OUT=S.CMP_OUT2
	from @ORDEROPT O 
		join PR_MODEL_OPTIONS S on O.MODELID=S.MODELID and O.OPTION_ID=S.OPTIONID
	where S.CMP_OUT2_OVERRIDE=1

update @ORDEROPT set CMP_REQ=S.CMP_REQ
	from @ORDEROPT O 
		join PR_MODEL_OPTIONS S on O.MODELID=S.MODELID and O.OPTION_ID=S.OPTIONID
	where S.CMP_REQ_OVERRIDE=1

update @ORDEROPT set CMP_BLOCK=S.CMP_BLOCK
	from @ORDEROPT O 
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
             FROM @ORDEROPT T
             CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_REQ)) REQ
LEFT JOIN(   SELECT 
                           OPTION_ID
                           ,OPTION_NAME
                           ,RTRIM(LTRIM(ITEM)) AS ITEM 
							,MODELID
                    FROM @ORDEROPT T
                    CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_OUT)) AS USED ON REQ.ITEM = USED.ITEM and REQ.MODELID=USED.MODELID
WHERE
       USED.ITEM IS NULL 

OPEN REQ_OPTIONS
FETCH NEXT FROM REQ_OPTIONS INTO @OPTION_ID, @OPTION, @TAG,@MODEL_NAME
WHILE @@FETCH_STATUS = 0
BEGIN
    set @errMess = '#WOption "'+ @OPTION + '" of model "' + @MODEL_NAME + '" requires another Option with Output Compatibility Parameter "'+@TAG + '".'
    if @BlockIncosistent = 1
    begin
       raiserror(@errMess, 16, 0) 
    end
    else
    begin
       PRINT @errMess
    end
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
             FROM @ORDEROPT T
             CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_BLOCK)) BLCK
 JOIN(   SELECT 
                           OPTION_ID
                           ,OPTION_NAME
                           ,RTRIM(LTRIM(ITEM)) AS ITEM 
							,MODELID
                    FROM @ORDEROPT T
                    CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_OUT)) AS USED ON BLCK.ITEM = USED.ITEM and BLCK.MODELID=USED.MODELID


OPEN BLOCK_OPTIONS
FETCH NEXT FROM BLOCK_OPTIONS INTO @OPTION_ID, @OPTION, @TAG, @OPTION_BLOCKING,@MODEL_NAME
WHILE @@FETCH_STATUS = 0
BEGIN
    set @errMess = '#WOption "'+ @OPTION + '" of model "' + @MODEL_NAME + '" is not compatable with Option "' + @OPTION_BLOCKING + '" (Output Compatibility Parameter "'+@TAG + '").'
    if @BlockIncosistent = 1
    begin
       raiserror(@errMess, 16, 0) 
    end
    else
    begin
       PRINT @errMess
    end
    FETCH NEXT FROM BLOCK_OPTIONS INTO @OPTION_ID, @OPTION, @TAG, @OPTION_BLOCKING,@MODEL_NAME
END
CLOSE BLOCK_OPTIONS
DEALLOCATE BLOCK_OPTIONS


set nocount off




/*
set nocount on

DECLARE 
             @OPTION_ID INT
             ,@OPTION NVARCHAR(200)
             ,@TAG NVARCHAR(255)

declare @BlockIncosistent int
declare @errMess nvarchar(max)

select @BlockIncosistent = isnull(B.BLOCKBYCOMPATIPRMS,0) 
from PR_PRORDER A with (nolock)
left join COM_DEPARTMENTS B with (nolock) on B.ID = A.DEPARTMENTID
where A.ID =  @ContextID


DECLARE @ORDEROPT TABLE (ORDER_ID INT, OPTION_ID INT, OPTION_NAME NVARCHAR(255), CMP_OUT NVARCHAR(200), CMP_REQ NVARCHAR(200))

INSERT INTO @ORDEROPT
SELECT 
       ORD.ID AS ORDER_ID
       ,MTOP.ID AS OPTION_ID
       ,MTOP.NAME AS OPTION_NAME
       ,MTOP.CMP_OUT AS CMP_OUT
       ,MTOP.CMP_REQ AS CMP_REQ
FROM PR_PRORDER ORD
LEFT JOIN PR_PRORDER_T ORDT ON ORD.ID = ORDT.PRORDERID
       LEFT JOIN PR_PRORDER_TO ORDOP ON  ORDT.ID = ORDOP.OPID
             LEFT JOIN PR_MODELTYPE_OPTIONS MTOP ON ORDOP.OPTID = MTOP.ID
WHERE
       ORD.ID = @ContextID

DECLARE REQ_OPTIONS CURSOR local read_only FOR 
SELECT DISTINCT
       REQ.OPTION_ID
       ,REQ.OPTION_NAME
       ,REQ.ITEM
FROM ( SELECT 
                    OPTION_ID
                    ,OPTION_NAME
                    ,RTRIM(LTRIM(ITEM)) AS ITEM 
             FROM @ORDEROPT T
             CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_REQ)) REQ
LEFT JOIN(   SELECT 
                           OPTION_ID
                           ,OPTION_NAME
                           ,RTRIM(LTRIM(ITEM)) AS ITEM 
                    FROM @ORDEROPT T
                    CROSS APPLY dbo.COM_STR2TABLE_STR(T.CMP_OUT)) AS USED ON REQ.ITEM = USED.ITEM
WHERE
       USED.ITEM IS NULL 

OPEN REQ_OPTIONS
FETCH NEXT FROM REQ_OPTIONS INTO @OPTION_ID, @OPTION, @TAG
WHILE @@FETCH_STATUS = 0
BEGIN
    set @errMess = '#WOption "'+ @OPTION + '" requires another Option with Output Compatibility Parameter "'+@TAG + '".'
    if @BlockIncosistent = 1
    begin
       raiserror(@errMess, 16, 0) 
    end
    else
    begin
       PRINT @errMess
    end
    FETCH NEXT FROM REQ_OPTIONS INTO @OPTION_ID, @OPTION, @TAG
END
CLOSE REQ_OPTIONS
DEALLOCATE REQ_OPTIONS


set nocount off

*/