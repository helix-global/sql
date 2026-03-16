CREATE procedure [dbo].[COM_TRAINING_OPERATIONS_DETACH]
( 
    @TRAININGID int
)
AS

    declare @t table (id INT)
    declare @id int

    INSERT INTO @t
    select ID
        from PR_OPERATION
        where ID in (select OPERID from COM_TRAINING_OPERATIONS where TRAININGID=@TRAININGID)
                or 
                    ID in (select OPERID from COM_TRAINING_PREPARATORY where TRAINING_ID=@TRAININGID)
                or
                    ID in (select OPERID from COM_TRAINING_MAINTENANCE where TRAININGID=@TRAININGID)

    DECLARE cur_COM_TRAINING_OPERATIONS_DETACH CURSOR FOR
    SELECT ID from @t
                    
    OPEN cur_COM_TRAINING_OPERATIONS_DETACH

    FETCH NEXT FROM cur_COM_TRAINING_OPERATIONS_DETACH INTO @id

    WHILE @@FETCH_STATUS=0
    BEGIN
    --если операция уже прикреплена к другим тренингам, не обнуляем поле USERINTRAINING
        if not exists(select OPERID from COM_TRAINING_OPERATIONS where TRAININGID<>@TRAININGID and OPERID=@id
                        union
                        select OPERID from COM_TRAINING_PREPARATORY where TRAINING_ID<>@TRAININGID and OPERID=@id
                        union
                        select OPERID from COM_TRAINING_MAINTENANCE where TRAININGID<>@TRAININGID and OPERID=@id
                    )
            update PR_OPERATION
                set USERINTRAINING=null
                where ID=@id
    
        FETCH NEXT FROM cur_COM_TRAINING_OPERATIONS_DETACH INTO @id
    END

    CLOSE cur_COM_TRAINING_OPERATIONS_DETACH
    DEALLOCATE cur_COM_TRAINING_OPERATIONS_DETACH

    update COM_TRAINING_OPERATIONS set OPERID=null
        where TRAININGID=@TRAININGID
    
    update COM_TRAINING_PREPARATORY set OPERID=null
        where TRAINING_ID=@TRAININGID
    
    update COM_TRAINING_MAINTENANCE set OPERID=null
        where TRAININGID=@TRAININGID