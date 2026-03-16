CREATE procedure [dbo].[COM_TRAINING_OPERATION_DETACH]
( 
    @trainingId int, @operId int, @mode int 
)
AS

    /*
    @mode: 
    1 - operation
    2 - preparatory
    3 - maintenance
    */

    if @trainingId is null or @operId is null 
        return

    --если операция уже прикреплена к другим тренингам, не обнуляем поле USERINTRAINING
    if not exists(select OPERID from COM_TRAINING_OPERATIONS where TRAININGID<>@trainingId and OPERID=@operId
                union
                select OPERID from COM_TRAINING_PREPARATORY where TRAINING_ID<>@trainingId and OPERID=@operId
                union
                select OPERID from COM_TRAINING_MAINTENANCE where TRAININGID<>@trainingId and OPERID=@operId
            )
        update PR_OPERATION
            set USERINTRAINING=null
            where ID=@operId