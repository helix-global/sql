CREATE PROCEDURE [dbo].[COM_CHECK_AND_ADD_WORKTIME2](
	 @EmoployeeID int
	,@UserID int
	,@OperActionDT DATETIME
	,@OPER_ACTION INT -- (действие над операцией 1 - отрывается, 2 - закрывается)
	,@WT_OVER_VAL INT = 10 -- временной интервал, в течении котрого переработка создаётся автоматически
)
AS
BEGIN
set nocount on

/*
27.05.2022 переписана почти заново из-за KB3228 
*/

declare @wtID int = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@EmoployeeID,@OperActionDT)

--запрет на автоматическое создание overtime KB3775 15.02.2023
declare @RestrictOvertime int = 0

if @wtID is null
begin
   set nocount off
   return
end   


DECLARE @DIFF INT

IF @OPER_ACTION = 1 -- если происходит открытие операции
BEGIN

	DECLARE @WT_START_DATE DATETIME
	
	SELECT top 1 @WT_START_DATE = A.WTURNBEG
	from dbo.COM_TURNS_AROUND(@OperActionDT,@wtID,@EmoployeeID) A
    where (A.ACTIVATEDWTURN = 1 or A.ONLYONEWTURN = 1)
      and A.ISWORKDAYOFWEEK = 1
    order by A.DIFFABS
	
	SET @DIFF = DATEDIFF(MINUTE, @OperActionDT, @WT_START_DATE) -- вычисляем разницу в минутах между началом операции и началом рабочего дня

	IF @DIFF BETWEEN 0 AND @WT_OVER_VAL -- если разница укладывается во временной интервал, в течении котрого переработка создаётся автоматически, 
	BEGIN
	    -- 15.02.2023
		-- проверяем есть ли запрет на создание автоматических переработок KB3775 (непосредственно перед планируемым вызовом создания переработки)
		-- (что бы не выполнять каждый раз при вызове процедуры)
		set @RestrictOvertime = (select top 1 isnull(RESTRICTOVERTIMES,0) from dbo.COM_WORKTIME where ID = @wtID)
		if @RestrictOvertime = 0 -- и если нет запрето, то
		BEGIN
			-- создаем переработку
			INSERT INTO COM_ADDED_WORKTIME(GID, S_CR, S_CDT, EMPLID, DBEG, DEND, AUTOADDEDTIME)
			VALUES (NEWID(), @UserID, GETDATE(), @EmoployeeID, @OperActionDT, @WT_START_DATE , 1)
		END
	END
END


IF @OPER_ACTION = 2 -- если происходит закрытие операции
BEGIN
	declare	@WT_END_DATE DATETIME
	
	SELECT top 1 @WT_END_DATE = A.WTURNEND
	from dbo.COM_TURNS_AROUND(@OperActionDT,@wtID,@EmoployeeID) A
    where (A.ACTIVATEDWTURN = 1 or A.ONLYONEWTURN = 1)
      and A.ISWORKDAYOFWEEK = 1
    order by A.DIFFABS_END	
		
	SET @DIFF = DATEDIFF(MINUTE, @WT_END_DATE, @OperActionDT) -- вычисляем разницу в минутах между окончанием рабочего дня и окончанием операции

	IF @DIFF BETWEEN 0 AND @WT_OVER_VAL -- если разница укладывается во временной интервал, в течении которого переработка создаётся автоматически, 
	BEGIN
	    update COM_ADDED_WORKTIME set DEND = @OperActionDT where EMPLID = @EmoployeeID and DBEG = @WT_END_DATE and AUTOADDEDTIME = 2
	    if @@rowcount = 0
	    begin
			-- 15.02.2023
			-- проверяем есть ли запрет на создание автоматических переработок KB3775 (непосредственно перед планируемым вызовом создания переработки)
			-- (что бы не выполнять каждый раз при вызове процедуры)
			set @RestrictOvertime  = (select top 1 isnull(RESTRICTOVERTIMES,0) from dbo.COM_WORKTIME where ID = @wtID)
			if @RestrictOvertime = 0 -- и если нет запрета, то
			BEGIN
				-- создаем переработку
				INSERT INTO COM_ADDED_WORKTIME(GID, S_CR, S_CDT, EMPLID, DBEG, DEND, AUTOADDEDTIME)
				VALUES (NEWID(), @UserID, GETDATE(), @EmoployeeID, @WT_END_DATE, @OperActionDT, 2)
			END
        end
	END
END

set nocount off

END