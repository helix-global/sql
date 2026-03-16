
CREATE FUNCTION dbo.COM_QUART
(
	@date datetime
)
RETURNS int
AS
BEGIN

	
	DECLARE @ret int


	set @ret = case 
				when @date is null then 0
				when MONTH(@date) IN (1,2,3) then 1
				when MONTH(@date) IN (4,5,6) then 2
				when MONTH(@date) IN (7,8,9) then 3
				when MONTH(@date) IN (10,11,12) then 4 end

	RETURN @ret

END