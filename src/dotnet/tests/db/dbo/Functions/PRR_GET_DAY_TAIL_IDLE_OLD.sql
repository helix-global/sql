CREATE FUNCTION [dbo].[PRR_GET_DAY_TAIL_IDLE_OLD]
(
	@EMPLOYEE_ID INT 
	,@DATE DATETIME
	,@WKT_ID INT
)
RETURNS INT
AS
BEGIN
-- =============================================
-- Граматкин А.В.
-- 04.07.2014
-- Вычисление "хвоста" простоя. Т.е. времени простоя между последней операцией за день и временем окончания рабочего дня (или переработки) в минутах.
-- =============================================


	-- Declare the return variable here
	DECLARE @RESULT INT = 0

	DECLARE @LAST_OPER_DEND DATETIME
			,@LAST_ADD_WKT_DEND DATETIME
			,@LAST_WKT_DEND DATETIME
-- если существуют операции, переходящие на следующие дни			
	IF EXISTS(	SELECT 
					ID 
				FROM PR_OPERATION_TIME  
				WHERE 
					EMPID = @EMPLOYEE_ID
				AND
					(
						(DBEG < @DATE AND DEND > DATEADD(DAY,1 , @DATE)) -- операции, начавшиеся не в @DATE и завершённые не в @DATE
					OR
						(DBEG > @DATE AND DBEG < DATEADD(DAY,1 , @DATE) AND DEND > DATEADD(DAY,1 , @DATE)) -- операции, начавшиеся в @DATE, но завершённые не в @DATE
					)
				)
		RETURN @RESULT
		--SELECT @RESULT

	
--	дата / время завершения последней операции, начатой сегодня. DEND также будет лежать в границах @DATE (см. предыдущий IF)
	SELECT
		@LAST_OPER_DEND = MAX(DEND)
	FROM PR_OPERATION_TIME
	WHERE
		EMPID = @EMPLOYEE_ID
	AND
		DBEG >= @DATE AND DBEG < DATEADD(DAY, 1, @DATE)


-- дата / время	окончания последней переработки за @DATE
	SELECT
		@LAST_ADD_WKT_DEND = MAX(DEND)
	FROM COM_ADDED_WORKTIME ADD_WKT
	WHERE
		DBEG >= @DATE AND DBEG < DATEADD(DAY, 1, @DATE)
	AND
		ADD_WKT.EMPLID = @EMPLOYEE_ID	
	
declare @wturn int
select @wturn = A.WTURN from COM_TURNS A where A.EMPLID = @EMPLOYEE_ID and A.DD = cast(@DATE as date)
set @wturn = ISNULL(@wturn,1)	
	
-- дата / время окончания рабочего времени
	SELECT
		@LAST_WKT_DEND = MAX(TTO)
	FROM COM_WORKTIME_BR
	WHERE
		VNESHID = @WKT_ID
		and WTURN = @wturn

-- если не указаны ни переработка, ни интервалы рабочего времени
	IF @LAST_ADD_WKT_DEND IS NULL AND @LAST_WKT_DEND IS NULL
	BEGIN
		SET @RESULT = NULL
		RETURN @RESULT
	--	SELECT @RESULT
	END	
	
	--SELECT @LAST_OPER_DEND, @LAST_ADD_WKT_DEND, @LAST_WKT_DEND

	SET @LAST_WKT_DEND = CAST(CAST(@DATE AS DATE) AS DATETIME) + CAST(CAST(@LAST_WKT_DEND AS TIME) AS DATETIME)


	SELECT
		@RESULT =	CASE 
						WHEN @LAST_ADD_WKT_DEND IS NOT NULL AND @LAST_WKT_DEND IS NOT NULL THEN
							CASE
								WHEN @LAST_ADD_WKT_DEND > @LAST_WKT_DEND
									THEN dbo.COM_WORK_MINUTS(@LAST_OPER_DEND, @LAST_ADD_WKT_DEND, @WKT_ID, 1, @EMPLOYEE_ID)
								ELSE
									dbo.COM_WORK_MINUTS(@LAST_OPER_DEND, @LAST_WKT_DEND, @WKT_ID, 1, @EMPLOYEE_ID)
							END
						ELSE
							CASE
								WHEN @LAST_ADD_WKT_DEND IS NOT NULL THEN dbo.COM_WORK_MINUTS(@LAST_OPER_DEND, @LAST_ADD_WKT_DEND, @WKT_ID, 1, @EMPLOYEE_ID)
								ELSE dbo.COM_WORK_MINUTS(@LAST_OPER_DEND, @LAST_WKT_DEND, @WKT_ID, 1, @EMPLOYEE_ID)
							END
					END
	-- Return the result of the function
	RETURN @RESULT
	--SELECT @RESULT

END