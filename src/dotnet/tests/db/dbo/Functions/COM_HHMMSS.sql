
CREATE FUNCTION dbo.COM_HHMMSS 
(
	@h int, @m int, @s int
)
RETURNS nvarchar(20)
AS
BEGIN
	
	declare @res nvarchar(20) = ''

	set @h = ISNULL(@h,0)
	set @m = ISNULL(@m,0)
	set @s = ISNULL(@s,0)

	declare @div int

	if @s>59
	begin
		set @div = (@s - (@s % 60))/60
		set @m =@m + @div
		set @s = @s - @div*60 
	end
	

	if @m>59
	begin
		set @div = (@m - (@m % 60))/60
		set @h =@h + @div
		set @m = @m - @div*60 
	end

	set @res = CAST(@h as nvarchar(10)) + 'h ' + right('00' + CAST(@m as nvarchar(2)),2) + 'm ' + right('00' + CAST(@s as nvarchar(2)),2) + 's'

	return @res
END