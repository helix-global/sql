
CREATE FUNCTION dbo.COM_ADD_LEADING_ZEROES
(
	@inp_number int, @zero_count int
)
RETURNS nvarchar(100)
AS
BEGIN

	declare @inp_string nvarchar(10), @i int = 0

	set @inp_string = CAST(@inp_number as nvarchar(100))
	
	DECLARE @ret nvarchar(100)

	declare @zeroes nvarchar(100) = ''
	
	while @i<=@zero_count
	begin
		set @zeroes = @zeroes + '0'
		set @i = @i + 1
	end

	set @ret = RIGHT(@zeroes + @inp_string, @zero_count)

	return @ret

END