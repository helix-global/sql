CREATE PROCEDURE [dbo].[COM_CHECK_AND_ADD_WORKTIME](
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
12.06.2014
Gramatkin A.V.
Процедура проверяет время операции и , если время не попадает в WORKTIME на @WT_OVER_VAL минут, 
то автоматически создает переработку на разницу между временем операции и границей WORKTIME (началом или концом рабочего дня)
Перерывы не учитываются.
29.09.14 updated NDA
*/
declare	@OperActionDate DATETIME

set @OperActionDate = CAST(@OperActionDT as date)

declare @wturn int
select @wturn = A.WTURN from COM_TURNS A where A.EMPLID = @EmoployeeID and A.DD = @OperActionDate
set @wturn = ISNULL(@wturn,1)

declare @wtID int

select @wtID = isnull(WT_EMP.ID, WT_DEP.ID)
FROM COM_EMPLOYEE EMP
LEFT JOIN COM_WORKTIME WT_EMP ON WT_EMP.ID = EMP.PERSONALWT
LEFT JOIN COM_WORKTIME WT_DEP ON WT_DEP.DEPID = EMP.DEPID AND ISNULL(WT_DEP.WTDEFAULT, 0) = 1
WHERE EMP.ID = @EmoployeeID

if @wtID is null
begin
   set nocount off
   return
end   

DECLARE @DIFF INT

IF @OPER_ACTION = 1 -- если происходит открытие операции
BEGIN

	DECLARE @WT_START_DATE DATETIME
	
	SELECT @WT_START_DATE = min(@OperActionDate + cast(cast(TFROM as time) as datetime) + case when datepart(hour,TFROM) < 3 then 1 else 0 end)
	FROM COM_WORKTIME_BR A
	where A.VNESHID = @wtID
	  and A.WTURN = @wturn	

	SET @DIFF = DATEDIFF(MINUTE, @OperActionDT, @WT_START_DATE) -- вычисляем разницу в минутах между началом операции и началом рабочего дня

	IF @DIFF BETWEEN 0 AND @WT_OVER_VAL -- если разница укладывается во временной интервал, в течении котрого переработка создаётся автоматически, 
	BEGIN
		-- создаем переработку
        INSERT INTO COM_ADDED_WORKTIME(GID, S_CR, S_CDT, EMPLID, DBEG, DEND, AUTOADDEDTIME)
        VALUES (NEWID(), @UserID, GETDATE(), @EmoployeeID, @OperActionDT, @WT_START_DATE , 1)
	END
END


IF @OPER_ACTION = 2 -- если происходит закрытие операции
BEGIN
	declare	@WT_END_DATE DATETIME
	SELECT @WT_END_DATE = max(@OperActionDate + cast(cast(TTO as time) as datetime) + case when datepart(hour,TTO) < 3 then 1 else 0 end)
	FROM COM_WORKTIME_BR A
	where A.VNESHID = @wtID
	  and A.WTURN = @wturn	
	  
	set @WT_END_DATE = dbo.COM_SHIFT_WORKTIME_ENDTIME(@WT_END_DATE, @OperActionDT, @EmoployeeID)  
	
	SET @DIFF = DATEDIFF(MINUTE, @WT_END_DATE, @OperActionDT) -- вычисляем разницу в минутах между окончанием рабочего дня и окончанием операции

	IF @DIFF BETWEEN 0 AND @WT_OVER_VAL -- если разница укладывается во временной интервал, в течении которого переработка создаётся автоматически, 
	BEGIN
	    update COM_ADDED_WORKTIME set DEND = @OperActionDT where EMPLID = @EmoployeeID and DBEG = @WT_END_DATE and AUTOADDEDTIME = 2
	    if @@rowcount = 0
	    begin
		  -- создаем переработку
          INSERT INTO COM_ADDED_WORKTIME(GID, S_CR, S_CDT, EMPLID, DBEG, DEND, AUTOADDEDTIME)
          VALUES (NEWID(), @UserID, GETDATE(), @EmoployeeID, @WT_END_DATE, @OperActionDT, 2)
        end
	END
END

set nocount off
END