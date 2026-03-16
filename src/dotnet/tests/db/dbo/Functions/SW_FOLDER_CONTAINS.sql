CREATE FUNCTION [dbo].[SW_FOLDER_CONTAINS]
(
    @fId int
)
RETURNS TABLE 
AS
RETURN 
(
    with cte (ID, PARENTID, FILENAME, FILESIZE, LEV)
    as (
        select ID, PARENTID, FILENAME, FILESIZE, 0 as LEV
            from SW_STORAGE
            where ID=@fId
        union all
        select S.ID, S.PARENTID, S.FILENAME, S.FILESIZE, C.LEV + 1
            from SW_STORAGE S
                join cte C on S.PARENTID=C.ID
        )
    select ID, FILENAME, FILESIZE, LEV from cte
        where ID<>@fId
)