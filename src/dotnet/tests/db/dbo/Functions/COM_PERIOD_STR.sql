
CREATE FUNCTION [dbo].[COM_PERIOD_STR]
(
    @date1 datetime
    , @date2 datetime
)
RETURNS nvarchar(100)
AS
BEGIN
    declare @per nvarchar(100) = ''

    declare @dd int, @hh int, @mm int

    set @dd = (datediff(minute, @date1, @date2) - datediff(minute, @date1, @date2) % 1440)/1440
    set @hh = (datediff(minute, @date1, @date2) - datediff(minute, @date1, @date2) % 60)/60 - @dd * 24
    set @mm = datediff(minute, @date1, @date2) - 24 * @dd * 60 - 60 * @hh
    
    if @dd<>0
        set @per = @per + cast(@dd as nvarchar(10)) + ' d '

    if @hh<>0
        set @per = @per + cast(@hh as nvarchar(10)) + ' h '
    
    if @mm<>0
        set @per = @per + cast(@mm as nvarchar(10)) + ' m '

    return @per 
END