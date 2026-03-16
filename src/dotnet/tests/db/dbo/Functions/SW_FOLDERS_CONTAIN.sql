CREATE FUNCTION [dbo].[SW_FOLDERS_CONTAIN]
(
    @fIds nvarchar(1000)
)
RETURNS @ret TABLE (ID int, FILENAME nvarchar(255), FILESIZE int, LEV int)
AS
begin
    
    declare @t table (ID int)

    insert into @t (ID)
        select ID from dbo.COM_STR2TABLE_INT(@fIds)

    declare @id int
    while exists(select ID from @t)
    begin
        
        select @id=ID from @t

        insert into @ret
            select * from dbo.SW_FOLDER_CONTAINS(@id)

        delete from @t where ID=@id

    end

    return
end