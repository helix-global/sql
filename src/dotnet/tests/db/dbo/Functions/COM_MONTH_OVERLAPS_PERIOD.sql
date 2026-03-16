-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION COM_MONTH_OVERLAPS_PERIOD
(
	@year int, @month int, @date1 datetime, @date2 datetime
)
RETURNS int
AS
BEGIN

	declare @firstDate datetime
	declare @lastDate datetime

	set @firstDate = dbo.COM_ENCODE_DATE(@year,@month,1)
	set @lastDate = DATEADD(day,-1,DATEADD(month,1,@firstDate))

	if @date1 is null 
		return 0
		
	if @date2 is null
		set @date2 = DATEADD(day,1,@lastDate)
	
	if @date1<=@lastDate and @date2>=@firstDate
		return 1

	return 0
END