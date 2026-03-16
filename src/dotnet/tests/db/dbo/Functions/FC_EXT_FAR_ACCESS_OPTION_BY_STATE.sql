
CREATE FUNCTION [dbo].[FC_EXT_FAR_ACCESS_OPTION_BY_STATE]
(
    @state int
)
RETURNS int
AS
BEGIN
    
    DECLARE @ret int = -1

    if @state = 1000104 /*approved*/
        set @ret = 2

    if @state = 2130020 /*requested*/
        set @ret = 5

    if @state = 2130022 /*issued*/
        set @ret = 4

    if @state = 2130021 /*generated*/
        set @ret = 3

    RETURN @ret

END