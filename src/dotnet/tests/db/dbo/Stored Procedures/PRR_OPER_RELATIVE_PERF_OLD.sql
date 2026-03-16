CREATE PROCEDURE [dbo].[PRR_OPER_RELATIVE_PERF_OLD]
(
    @START_DATE DATETIME
    ,@END_DATE DATETIME
    ,@AVIABLE_OPERATIONS NVARCHAR(MAX)
)
AS
BEGIN
-- =============================================
-- Граматкин А.В.
-- 04.07.2014
-- ХП для отчета Operator performance
-- =============================================

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


    DECLARE @TMP_DEPTS TABLE(
                ID INT PRIMARY KEY
                ,NAME NVARCHAR(100)
            )


    DECLARE @TMP_OPERATIONS TABLE (
                ID INT PRIMARY KEY
                ,OPERTYPEID INT
                ,DEVICEID INT
                ,USR_PER_OPER INT
                ,PREP_RESULT INT
            )

    DECLARE @TMP_AVIABLE_OPER TABLE (
                ID INT
            )

    DECLARE @TMP_OPER_CNT TABLE (
                USERID INT PRIMARY KEY
                ,OPER_CNT INT
            )

    DECLARE @TMP_OPER_CNT_FULL TABLE(
                USERID INT PRIMARY KEY
                ,OPER_CNT INT
            )

    DECLARE @TMP_IDLE_TIMES TABLE(
                EMP_ID INT PRIMARY KEY
                ,IDLE_TIME INT
            )

    DECLARE @TMP_IDLE_T_OP TABLE(
                OPER_TIME_ID INT PRIMARY KEY
            )



    SELECT @START_DATE = DATEADD(day, DATEDIFF(day, 0,@START_DATE), 0)
    SELECT @END_DATE = DATEADD(DAY, 1, CAST(@END_DATE AS DATE))

    INSERT INTO @TMP_DEPTS
    SELECT 
        T.ID
        ,NAME
    FROM [dbo].[COM_ACCESS_DEPARTMENTS] (dbo.DEF_USERID(),3,GETDATE()) T
        JOIN COM_DEPARTMENTS DEPT ON T.ID = DEPT.ID

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
    FROM PR_OPERATION OP

    JOIN @TMP_AVIABLE_OPER OP_T ON OP.OPERTYPEID = OP_T.ID

    JOIN PR_OPERATION_TIME OP_TIME ON OP.ID = OP_TIME.OPERID
        JOIN DEF_USERS USR ON OP_TIME.USERID = USR.ID
            JOIN COM_EMPLOYEE EMP ON USR.EMPLOYEEID = EMP.ID


    --JOIN PR_OPERATIONS OP_TYPE ON OP.[OPERTYPEID] = OP_TYPE.ID
    --  JOIN [dbo].[PR_OPERATIONS_GR] OP_TYPE_GR ON OP_TYPE.[OPERGRID] = OP_TYPE_GR.[ID]
    

    WHERE
        (OP.COMPLETED_DT >= @START_DATE AND OP.COMPLETED_DT < @END_DATE)
    --AND
    --  EMP.DEPID IN (SELECT ID FROM @TMP_DEPTS)
    --AND
    --  OP_TYPE_GR.DEPARTMENTID IN (SELECT ID FROM @TMP_DEPTS)
    GROUP BY
        OP.ID, OP.OPERTYPEID, OP.DEVICEID, OP.PREP_RESULT

    INSERT INTO @TMP_OPER_CNT
    SELECT
        OP_T.USERID
        ,COUNT(DISTINCT OPERID) AS OPER_CNT
    FROM PR_OPERATION_TIME OP_T
    JOIN @TMP_OPERATIONS OP ON OP_T.OPERID = OP.ID
    WHERE
        OP.USR_PER_OPER = 1 
    GROUP BY 
        OP_T.USERID


    INSERT INTO @TMP_OPER_CNT_FULL
    SELECT
        OP_T.USERID
        ,COUNT(DISTINCT OPERID) AS OPER_CNT
    FROM PR_OPERATION_TIME OP_T
    JOIN @TMP_OPERATIONS OP ON OP_T.OPERID = OP.ID
    GROUP BY 
        OP_T.USERID
----------------------------------------------------------------------
--FIND TOTAL IDLE TIME OF THE EMPLOYEE
    --;WITH 
    --  CTE_TAIL_IT AS (
    --  SELECT
    --      T.EMP_ID
    --      ,SUM(REPORT.GET_DAY_TAIL_IDLE(T.EMP_ID,DBEG,WKT_ID)) AS IDLE_TIME
    --  FROM (
    --      SELECT DISTINCT
    --          EMP.ID AS EMP_ID
    --          ,CAST(CAST(DBEG AS DATE) AS DATETIME) AS DBEG
    --          ,ISNULL(EMP.PERSONALWT, WKT.ID) AS WKT_ID
    --      FROM COM_EMPLOYEE EMP
    --      JOIN PR_OPERATION_TIME OP_T ON OP_T.EMPID = EMP.ID
    --      JOIN @TMP_DEPTS DPT ON DPT.ID = EMP.DEPID
    --      LEFT JOIN COM_WORKTIME WKT ON EMP.DEPID = WKT.DEPID AND WKT.WTDEFAULT = 1
    --      WHERE
    --          OP_T.DBEG >= @START_DATE AND OP_T.DBEG < @END_DATE

    --       ) T
    --  GROUP BY T.EMP_ID)
    INSERT INTO @TMP_IDLE_T_OP
    SELECT 
        OP_T_ID
    FROM
     (
        SELECT
            OP_T.EMPID
            ,OP_T.ID AS OP_T_ID
            ,CAST(DBEG AS DATE) AS OP_DATE
        FROM PR_OPERATION_TIME OP_T
        JOIN COM_EMPLOYEE EMP ON OP_T.EMPID = EMP.ID    
            JOIN @TMP_DEPTS DPT ON DPT.ID = EMP.DEPID
        WHERE
            OP_T.DBEG >= @START_DATE AND OP_T.DBEG < @END_DATE
        
        EXCEPT

        SELECT
            OP_T.EMPID
            ,OP_T.ID
            ,CAST(DBEG AS DATE)
        FROM PR_OPERATION_TIME OP_T
        JOIN (SELECT
                EMPID
                ,MIN(DBEG) AS MAX_DBEG
                ,CAST(DBEG AS DATE) AS OPER_DAY
                FROM PR_OPERATION_TIME
                WHERE
                    DBEG >= @START_DATE AND DBEG < @END_DATE
                GROUP BY
                    EMPID, CAST(DBEG AS DATE)
                )MAX_DBEG ON OP_T.EMPID = MAX_DBEG.EMPID AND OP_T.DBEG = MAX_DBEG.MAX_DBEG

        JOIN COM_EMPLOYEE EMP ON OP_T.EMPID = EMP.ID    
            JOIN @TMP_DEPTS DPT ON DPT.ID = EMP.DEPID
    ) T


    ;WITH CTE_IT AS (
        SELECT
            OP_T.EMPID
            ,(SUM(CAST(OP_T.IDLE_TIME AS DECIMAL(16,4)))) AS IDLE_TIME
        FROM PR_OPERATION_TIME OP_T
        JOIN @TMP_IDLE_T_OP SEL_OP_T ON OP_T.ID = SEL_OP_T.OPER_TIME_ID
        GROUP BY  OP_T.EMPID
    )
    ,CTE_EL AS (
        SELECT
            OP_T.EMPID
            ,(SUM(CAST(ISNULL(OP_T.ELAPSEDCORR, OP_T.ELAPSED) AS DECIMAL(16,4))))  AS ELAPSED_TIME
        FROM PR_OPERATION_TIME OP_T
        WHERE
            OP_T.DBEG >= @START_DATE AND OP_T.DBEG < @END_DATE
        GROUP BY  OP_T.EMPID
    )


    INSERT INTO @TMP_IDLE_TIMES
    SELECT
        EMP.ID
        ,CASE 
            WHEN EL.ELAPSED_TIME = 0 THEN NULL
            ELSE IT.IDLE_TIME * 100 / (EL.ELAPSED_TIME + IT.IDLE_TIME)
            END

    FROM COM_EMPLOYEE EMP
    LEFT JOIN CTE_IT IT ON EMP.ID = IT.EMPID
    LEFT JOIN CTE_EL EL ON EMP.ID = EL.EMPID



----------------------------------------------------------------------
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
        FROM COM_EMPLOYEE EMP
        JOIN @TMP_DEPTS DEP ON EMP.DEPID = DEP.ID

        JOIN DEF_USERS USR ON EMP.ID = USR.EMPLOYEEID
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
                        FROM PR_OPERATION_TIME OP_T
                        JOIN @TMP_OPERATIONS CTE ON OP_T.OPERID = CTE.ID AND CTE.USR_PER_OPER =1
                        GROUP BY 
                            OP_T.USERID,OP_T.OPERID, CTE.DEVICEID, CTE.OPERTYPEID
                        ) OP_T ON USR.ID = OP_T.USERID

                LEFT JOIN PR_DEVICE DEV ON OP_T.DEVICEID = DEV.ID
                    LEFT JOIN PR_REV_OVER_MH REV_MH ON DEV.REVID = REV_MH.REVID AND REV_MH.OPERID = OP_T.OPERTYPEID

                LEFT JOIN PR_OPERATIONS OP_TYPE ON OP_T.OPERTYPEID = OP_TYPE.ID
        
                LEFT JOIN (SELECT 
                                MH.OPERID
                                ,DEV_OPT.DEVICEID
                                ,SUM(MH.MANHOUR2) AS MANHOUR
                            FROM PR_OPER_ADD_MH MH
                            JOIN PR_DEVICE_OPT DEV_OPT ON DEV_OPT.OPTID = MH.OPTID
                        
                            GROUP BY MH.OPERID, DEV_OPT.DEVICEID
                            ) ADD_MH ON ADD_MH.OPERID = OP_T.OPERTYPEID AND ADD_MH.DEVICEID = OP_T.DEVICEID
        WHERE
            NOT EXISTS (SELECT ID FROM DEF_USERSTOGROUP WHERE USERID = USR.ID AND GROUPID = 17)


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
END