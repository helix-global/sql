
CREATE FUNCTION dbo.COM_NEW_IMP_RECOMMEND_NUMBER
(
)
RETURNS nvarchar(11)
AS
BEGIN
	
	DECLARE @ret nvarchar(11)

	declare @baseDate nvarchar(8), @lastNum nvarchar(3), @lastNumInt int



	set @baseDate = [dbo].[COM_YYYYMMDD](GETDATE())

	select @lastNum = MAX(RIGHT(R.INITIATIVE_NUM,3))
		from COM_IMP_RECOMMENDATIONS R
			where R.INITIATIVE_NUM like @baseDate + '%'

	if @lastNum is null
		set @lastNum = '001'
	else
	begin
		set @lastNumInt = CAST(@lastNum as int) + 1
		set @lastNum = dbo.COM_ADD_LEADING_ZEROES(@lastNumInt,3)
	end

	set @ret = @baseDate + @lastNum
	
	RETURN @ret

END