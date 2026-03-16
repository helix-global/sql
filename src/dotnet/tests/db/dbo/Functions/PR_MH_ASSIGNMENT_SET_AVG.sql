
CREATE FUNCTION [dbo].[PR_MH_ASSIGNMENT_SET_AVG]
(
     @START_DATE datetime,
     @END_DATE datetime,
     @MANHOUR_ID int
)
RETURNS decimal(16,6)
AS
BEGIN
    declare @ret decimal(16,6)

    SET @END_DATE = DATEADD(DAY, 1, @END_DATE)

SELECT @ret = AVG(CAST(ELAPSED AS DECIMAL(16,2)))
FROM (
    SELECT
        SUM(COALESCE(OP_T.ELAPSEDCORR, OP_T.ELAPSED,0)) AS ELAPSED
    FROM PR_MH_ASSIGNMENT_T MH_T with (nolock)
    JOIN PR_MODELS MDL with (nolock) ON MH_T.MODELID = MDL.ID
    JOIN PR_REVISION REV with (nolock) ON MH_T.REVID = REV.ID
        JOIN PR_DEVICE DEV with (nolock) ON MDL.ID = DEV.MODELID AND REV.ID = DEV.REVID   
    
    JOIN PR_OPERATIONS OP_TP with (nolock) ON MH_T.OPERATION = OP_TP.ID
        JOIN PR_OPERATION OP with (nolock) ON OP.OPERTYPEID = OP_TP.ID AND OP.DEVICEID = DEV.ID
            LEFT JOIN PR_OPERATION_TIME OP_T with (nolock) ON OP.ID = OP_T.OPERID
    WHERE
        OP.COMPLETED_DT >= @START_DATE AND OP.COMPLETED_DT < @END_DATE
    AND
        MH_T.ID = @MANHOUR_ID
    GROUP BY 
        OP.ID
        ,MDL.ID
        ,MDL.NAME
        ,REV.ID
        ,REV.NAME
        ,OP_TP.ID
        ,OP_TP.NAME
        ,DEV.ID
        ,DEV.SN
        ,MH_T.CURRENTVALUE
) T

return @ret

END