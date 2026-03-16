
CREATE FUNCTION dbo.COM_MINUTES_TO_STR_HMM
(
	@minutes int
)
RETURNS nvarchar(20)
AS
BEGIN

	if @minutes is null
		return '0:00'
	
	DECLARE @ret nvarchar(10)
	declare @h int, @m int

	declare @minutesAbs int = abs(@minutes)
	
	set @h = @minutesAbs / 60
	set @m = @minutesAbs % 60

	set @ret = CAST(@h as nvarchar(7)) + 'h ' + RIGHT('0' + CAST(@m as nvarchar(2)),2) + 'm'
	if @minutes<0
		set @ret = '- ' + @ret

	RETURN @ret

END