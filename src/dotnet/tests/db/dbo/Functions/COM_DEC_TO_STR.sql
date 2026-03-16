

CREATE FUNCTION [dbo].[COM_DEC_TO_STR]
(
    @num decimal(10,2)
)
RETURNS  varchar(10)
AS
BEGIN
	/* for KB4263 */
	
	declare @ret varchar(10)
	set @ret = case when @num - FLOOR(@num) = 0 then convert(varchar(10),FLOOR(@num)) else convert(varchar(10),@num) end

	return isnull(@ret,'0')
END