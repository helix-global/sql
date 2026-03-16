
CREATE function [dbo].[COM_HOUR_DEC_TO_STR_HMM](@HoursDec decimal(10,2))
returns nvarchar(10) as 
begin
  /* KB2462 */
  /*выдает строку времени типа "5h 30m" из количества часов (5.5 например)в десятичном (переработка и т.д.) */
  /*Efimov MV*/

declare @sign nvarchar(2) = ''
if @HoursDec<0
	set @sign = '- '

set @HoursDec = ABS(@HoursDec) --FLOOR для отрицательных выдает меньшее число (-10.5 -> -11) 

declare @h int = FLOOR(@HoursDec)
declare @m int = FLOOR(convert(decimal, 60)/100  * PARSENAME(@HoursDec, 1))


declare @res nvarchar(10) = @sign + convert(varchar,@h) + 'h ' + RIGHT('00'+CAST(@m AS VARCHAR(2)),2) + 'm'

return @res
  
end