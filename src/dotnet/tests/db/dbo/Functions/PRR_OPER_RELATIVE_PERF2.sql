CREATE FUNCTION [dbo].[PRR_OPER_RELATIVE_PERF2]
(
    -- Add the parameters for the function here
    @START_DATE DATE
    ,@END_DATE DATE
    ,@AVIABLE_OPERATIONS NVARCHAR(MAX)
    ,@USER_ID INT
    ,@mode int
)
RETURNS 
@RES TABLE 
(
        EMPID INT
        ,NAME NVARCHAR(255)
        ,DEPT_NAME NVARCHAR(255)
        ,AVG_DISP DECIMAL(10,4)
        ,EMPLOYEE_ONLY_OPERATIONS INT
        ,EMPLOYEE_COMMON_OPERATIONS INT
        ,AVG_IDLE_TIME INT
)
AS
BEGIN


declare @spvGroup int = 17
if @mode = 1
  set @spvGroup = -21481/*не существующее значение*/
    
DECLARE @TMP_DEPTS TABLE(ID INT PRIMARY KEY,NAME NVARCHAR(100))
DECLARE @TMP_OPERATIONS TABLE (ID INT PRIMARY KEY,OPERTYPEID INT,DEVICEID INT,USR_PER_OPER INT,PREP_RESULT INT)
DECLARE @TMP_AVIABLE_OPER TABLE (ID INT PRIMARY KEY)
DECLARE @TMP_OPER_CNT TABLE (USERID INT PRIMARY KEY,OPER_CNT INT)
DECLARE @TMP_OPER_CNT_FULL TABLE(USERID INT PRIMARY KEY,OPER_CNT INT)

    DECLARE @TMP_IDLE_TIMES TABLE(
                EMP_ID INT PRIMARY KEY
                ,IDLE_TIME INT
            )

DECLARE @TMP_IDLE_T_OP TABLE(
                ROW_NUM INT
                ,EMPID INT
                ,ELAPSED DECIMAL(16,4)
                ,IDLE DECIMAL(16,4)
            )


    SELECT @START_DATE = DATEADD(day, DATEDIFF(day, 0,@START_DATE), 0)
    SELECT @END_DATE = DATEADD(DAY, 1, CAST(@END_DATE AS DATE))

    INSERT INTO @TMP_DEPTS
    SELECT DISTINCT
        T.ID
        ,NAME
    FROM [dbo].[COM_ACCESS_DEPARTMENTS] (@USER_ID,3,GETDATE()) T
        JOIN COM_DEPARTMENTS DEPT with (nolock) ON T.ID = DEPT.ID

    INSERT INTO @TMP_AVIABLE_OPER
    SELECT Item = CONVERT(INT, Item) FROM
          ( SELECT Item = x.i.value('(./text())[1]', 'varchar(max)')
            FROM ( SELECT [XML] = CONVERT(XML, '<i>'
            + REPLACE(@AVIABLE_OPERATIONS, ',', '</i><i>') + '</i>').query('.')
              ) AS a CROSS APPLY [XML].nodes('i') AS x(i) ) AS y
          WHERE Item IS NOT NULL

    INSERT INTO @TMP_OPERATIONS
    SELECT
        OP.ID
        ,OP.OPERTYPEID
        ,OP.DEVICEID
        ,COUNT(DISTINCT OP_TIME.USERID) AS USR_PER_OPER
        ,OP.PREP_RESULT
    FROM PR_OPERATION OP with (nolock)

    JOIN @TMP_AVIABLE_OPER OP_T ON OP.OPERTYPEID = OP_T.ID

    JOIN PR_OPERATION_TIME OP_TIME with (nolock) ON OP.ID = OP_TIME.OPERID
        JOIN DEF_USERS USR with (nolock) ON OP_TIME.USERID = USR.ID
            JOIN COM_EMPLOYEE EMP with (nolock) ON USR.EMPLOYEEID = EMP.ID

    WHERE
        (OP.COMPLETED_DT >= @START_DATE AND OP.COMPLETED_DT < @END_DATE)
    GROUP BY
        OP.ID, OP.OPERTYPEID, OP.DEVICEID, OP.PREP_RESULT

    INSERT INTO @TMP_OPER_CNT
    SELECT
        OP_T.USERID
        ,COUNT(DISTINCT OPERID) AS OPER_CNT
    FROM PR_OPERATION_TIME OP_T with (nolock)
    JOIN @TMP_OPERATIONS OP ON OP_T.OPERID = OP.ID
    WHERE
        OP.USR_PER_OPER = 1 
    GROUP BY 
        OP_T.USERID


    INSERT INTO @TMP_OPER_CNT_FULL
    SELECT
        OP_T.USERID
        ,COUNT(DISTINCT OPERID) AS OPER_CNT
    FROM PR_OPERATION_TIME OP_T with (nolock)
    JOIN @TMP_OPERATIONS OP ON OP_T.OPERID = OP.ID
    GROUP BY 
        OP_T.USERID
        
    INSERT INTO @TMP_IDLE_T_OP(ROW_NUM,EMPID,ELAPSED,IDLE)
        SELECT
            ROW_NUMBER() OVER (PARTITION BY EMPID, CAST(DBEG AS DATE) ORDER BY CAST(DBEG AS DATE)) AS RN
            ,EMPID
            ,COALESCE(OP_T.ELAPSEDCORR, OP_T.ELAPSED, 0)
            ,ISNULL(IDLE_TIME, 0)
        FROM PR_OPERATION_TIME OP_T with (nolock)
        JOIN COM_EMPLOYEE EMP with (nolock) ON OP_T.EMPID = EMP.ID    
            JOIN @TMP_DEPTS DPT  ON DPT.ID = EMP.DEPID
        WHERE
            OP_T.DBEG >= @START_DATE AND OP_T.DBEG < @END_DATE

    DECLARE @CTE_IT TABLE (EMPID INT PRIMARY KEY, IDLE_TIME DECIMAL(16,4))
    INSERT INTO @CTE_IT
        SELECT
            EMPID
            ,SUM(IDLE)
        FROM @TMP_IDLE_T_OP
        WHERE
            ROW_NUM != 1
        GROUP BY  EMPID
    
    DECLARE @CTE_EL TABLE (EMPID INT PRIMARY KEY, ELAPSED_TIME DECIMAL(16,4))

    INSERT INTO  @CTE_EL
        SELECT
            EMPID
            ,SUM(ELAPSED)  AS ELAPSED_TIME
        FROM @TMP_IDLE_T_OP
        GROUP BY EMPID

    


    INSERT INTO @TMP_IDLE_TIMES
    SELECT
        EMP.ID
        ,CASE 
            WHEN EL.ELAPSED_TIME = 0 THEN NULL
            ELSE IT.IDLE_TIME * 100 / (EL.ELAPSED_TIME + IT.IDLE_TIME)
            END

    FROM COM_EMPLOYEE EMP with (nolock)
    LEFT JOIN @CTE_IT IT ON EMP.ID = IT.EMPID
    LEFT JOIN @CTE_EL EL ON EMP.ID = EL.EMPID
----------------------------------------------------------------------
    INSERT INTO @RES
    SELECT
        EMPID
        ,NAME
        ,DEPT_NAME
        ,(SUM(ELAPSED_TIME) - SUM(MANHOUR)) / (SUM(MANHOUR)/100)  AS AVG_DISP
        ,ONLY_OP.OPER_CNT AS EMPLOYEE_ONLY_OPERATIONS
        ,FULL_OP.OPER_CNT AS EMPLOYEE_COMMON_OPERATIONS
        ,IT.IDLE_TIME AS AVG_IDLE_TIME

    FROM (

        SELECT
            EMP.ID AS EMPID
            ,EMP.NAME
            ,USR.ID AS USERID
            ,OP_T.OPERID
            ,OP_T.ELAPSED_TIME
            ,COALESCE(REV_MH.MANHOUR2, OP_TYPE.MANHOUR, 0)+ COALESCE(ADD_MH.MANHOUR, 0) AS MANHOUR
            ,DEP.NAME AS DEPT_NAME
        FROM COM_EMPLOYEE EMP with (nolock)
        JOIN @TMP_DEPTS DEP ON EMP.DEPID = DEP.ID

        JOIN DEF_USERS USR with (nolock) ON EMP.ID = USR.EMPLOYEEID
            JOIN (SELECT
                        OP_T.USERID
                        ,OP_T.OPERID
                        ,CTE.DEVICEID
                        ,CTE.OPERTYPEID
                        ,SUM(
                                CASE
                                    WHEN ISNULL(CTE.PREP_RESULT,0) > 1 THEN COALESCE(OP_T.ELAPSEDCORR, OP_T.ELAPSED, 0)/CTE.PREP_RESULT
                                    ELSE COALESCE(OP_T.ELAPSEDCORR, OP_T.ELAPSED, 0)
                                END
                            ) AS ELAPSED_TIME
                        FROM PR_OPERATION_TIME OP_T with (nolock)
                        JOIN @TMP_OPERATIONS CTE ON OP_T.OPERID = CTE.ID AND CTE.USR_PER_OPER =1
                        GROUP BY 
                            OP_T.USERID,OP_T.OPERID, CTE.DEVICEID, CTE.OPERTYPEID
                        ) OP_T ON USR.ID = OP_T.USERID

                LEFT JOIN PR_DEVICE DEV with (nolock) ON OP_T.DEVICEID = DEV.ID
                    LEFT JOIN PR_REV_OVER_MH REV_MH with (nolock) ON DEV.REVID = REV_MH.REVID AND REV_MH.OPERID = OP_T.OPERTYPEID

                LEFT JOIN PR_OPERATIONS OP_TYPE with (nolock) ON OP_T.OPERTYPEID = OP_TYPE.ID
        
                LEFT JOIN (SELECT 
                                MH.OPERID
                                ,DEV_OPT.DEVICEID
                                ,SUM(MH.MANHOUR2) AS MANHOUR
                            FROM PR_OPER_ADD_MH MH with (nolock)
                            JOIN PR_DEVICE_OPT DEV_OPT with (nolock) ON DEV_OPT.OPTID = MH.OPTID
                        
                            GROUP BY MH.OPERID, DEV_OPT.DEVICEID
                            ) ADD_MH ON ADD_MH.OPERID = OP_T.OPERTYPEID AND ADD_MH.DEVICEID = OP_T.DEVICEID
        WHERE
            NOT EXISTS (SELECT ID FROM DEF_USERSTOGROUP with (nolock) WHERE USERID = USR.ID AND GROUPID = @spvGroup)
        ) T
    LEFT JOIN  @TMP_OPER_CNT ONLY_OP ON T.USERID = ONLY_OP.USERID
    LEFT JOIN  @TMP_OPER_CNT_FULL FULL_OP ON T.USERID = FULL_OP.USERID

    LEFT JOIN @TMP_IDLE_TIMES IT ON T.EMPID = IT.EMP_ID
    WHERE 
        MANHOUR != 0

    GROUP BY 
        EMPID, NAME, DEPT_NAME, ONLY_OP.OPER_CNT,FULL_OP.OPER_CNT, IDLE_TIME
    ORDER BY 
        AVG_DISP

    
    RETURN 
END