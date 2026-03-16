
CREATE FUNCTION [dbo].[PR_PRODUCTION_PLAN_bak]
(
        @DEPID INT
       ,@START_DATE DATETIME
       ,@END_DATE DATETIME
)
RETURNS @RESULT TABLE (
             CUSTOMER_ID INT
             ,ID INT
             ,PRODUCTION_ORDER_NUM NVARCHAR(50)
             ,SALES_ORDER_NUM NVARCHAR(50)
             ,ORDER_DATE DATETIME
             ,ORDER_EXPECTED_DATE DATETIME
             ,MODEL_ID INT
             ,REVISION_ID INT 
             ,ORDERED_QTY INT
             ,TOT_SHIPPED_DEVICE_QTY INT
             ,S_S INT
             ,REST_QTY int             
)
AS 
BEGIN


SELECT @END_DATE = DATEADD(DAY, 1, @END_DATE);




INSERT INTO @RESULT
SELECT
       *
      ,ORDERED_QTY - TOT_SHIPPED_DEVICE_QTY
FROM (
       SELECT
             CST.ID AS CUSTOMER_ID
             ,ORD.ID AS ORDER_ID
             ,ORD.NN AS PRODUCTION_ORDER_NUM
             ,ISNULL(ORD.NN2, 'NA') AS SALES_ORDER_NUM
             ,ORD.DD AS ORDER_DATE
             ,ORD.EXPDATE AS ORDER_EXECTED_DATE
             ,MDL.ID AS MODEL_ID
             ,REV.ID AS REVISION_ID
             ,isnull(ORD_T.QUANTITY,0) AS ORDERED_QTY
             ,isnull(SHIP_DEV.TOT_SHIPPED_DEVICE_QTY,0) as TOT_SHIPPED_DEVICE_QTY
             ,ORD.S_S 
       FROM COM_CUSTOMER CST
       JOIN PR_PRORDER ORD ON CST.ID = ORD.CUSTOMERID
             LEFT JOIN PR_PRORDER_T ORD_T ON ORD.ID = ORD_T.PRORDERID
                    LEFT JOIN PR_MODELS MDL ON ORD_T.MODELID = MDL.ID
                    LEFT JOIN PR_REVISION REV ON ORD_T.REVID = REV.ID
       
                           LEFT JOIN ( SELECT
                                                      ORDERID
                                                      ,MODELID
                                                      ,REVID
                                                      ,COUNT(ID) AS TOT_SHIPPED_DEVICE_QTY
                                               FROM PR_DEVICE
                                               WHERE
                                                      SHIPPED_DT IS NOT NULL
                                               GROUP BY ORDERID, MODELID, REVID 
                                               )SHIP_DEV ON SHIP_DEV.ORDERID = ORD_T.PRORDERID 
                                                                   AND SHIP_DEV.MODELID = ORD_T.MODELID 
                                                                   AND SHIP_DEV.REVID = ORD_T.REVID
       
       WHERE 
             ORD.EXPDATE >= @START_DATE AND ORD.EXPDATE < @END_DATE 
       AND
             ORD.DEPARTMENTID = @DEPID
       AND
             ORD.ORDERTYPE = 0          
       
       UNION
       
       SELECT
             CST.ID AS CUSTOMER_ID
             ,ORD.ID AS ORDER_ID
             ,ORD.NN AS PRODUCTION_ORDER_NUM
             ,ISNULL(ORD.NN2, 'NA') AS SALES_ORDER_NUM
             ,ORD.DD AS ORDER_DATE
             ,ORD.EXPDATE AS ORDER_EXECTED_DATE
             ,MDL.ID AS MODEL_ID
             ,REV.ID AS REVISION_ID
             ,isnull(ORD_T.QUANTITY,0) AS ORDERED_QTY
             ,isnull(SHIP_DEV.TOT_SHIPPED_DEVICE_QTY,0) as TOT_SHIPPED_DEVICE_QTY
             ,ORD.S_S 
       FROM COM_CUSTOMER CST
       JOIN PR_PRORDER ORD ON CST.ID = ORD.CUSTOMERID
             LEFT JOIN PR_PRORDER_T ORD_T ON ORD.ID = ORD_T.PRORDERID
                    LEFT JOIN PR_MODELS MDL ON ORD_T.MODELID = MDL.ID
                    LEFT JOIN PR_REVISION REV ON ORD_T.REVID = REV.ID
       
                           LEFT JOIN ( SELECT
                                                      ORDERID
                                                      ,MODELID
                                                      ,REVID
                                                      ,COUNT(ID) AS TOT_SHIPPED_DEVICE_QTY
                                               FROM PR_DEVICE
                                               WHERE
                                                      SHIPPED_DT IS NOT NULL
                                               GROUP BY ORDERID, MODELID, REVID 
                                               )SHIP_DEV ON SHIP_DEV.ORDERID = ORD_T.PRORDERID 
                                                                   AND SHIP_DEV.MODELID = ORD_T.MODELID 
                                                                   AND SHIP_DEV.REVID = ORD_T.REVID
       
       WHERE 
             EXISTS(SELECT 
                                  1 
                           FROM PR_DEVICE 
                           WHERE 
                                  SHIPPED_DT >= @START_DATE AND SHIPPED_DT < @END_DATE
                           AND
                                  ORDERID = ORD.ID
                           AND
                                  MODELID = ORD_T.MODELID
                           AND
                                  REVID = ORD_T.REVID
                           )
       AND
             ORD.DEPARTMENTID = @DEPID
       AND
             ORD.ORDERTYPE = 0          
             
) T

RETURN
END