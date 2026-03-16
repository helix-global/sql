CREATE function [dbo].[COM_CHECK_TRAINING_OPERATIONS_NUMBER]
(
    @trainingID int, 
    @mode int  /* 1 - проверка на количество успешно завершенных либо не завершенных операций (т.е. кроме НЕ утвержденных тренером) 
                  2 - проверка на количество успешно завершенных операций
                  */
)
returns int
AS
begin

    declare @ret int

    set @ret = 0

    declare @skillNumOperations int, 
            @numOperationsCompleted int,            
            @numPreparatoryCompleted int, 
            @numMaintenanceCompleted int, 
            @numOperationsNotCompleted int,             
            @numPreparatoryNotCompleted int, 
            @numMaintenanceNotCompleted int, 
            @skillId int

    select @numOperationsCompleted=ISNULL(SUM(case when O.TRAINING_STATE=1 then 1 else 0 end),0)
        , @numOperationsNotCompleted=ISNULL(SUM(case when O.TRAINING_STATE is null then 1 else 0 end),0)
    from COM_TRAINING_OPERATIONS O
    where O.TRAININGID=@trainingID

    select @numPreparatoryCompleted=ISNULL(SUM(case when O.TRAINING_STATE=1 then 1 else 0 end),0)
        , @numPreparatoryNotCompleted=ISNULL(SUM(case when O.TRAINING_STATE is null then 1 else 0 end),0)
    from COM_TRAINING_PREPARATORY O
    where O.TRAINING_ID=@trainingID

    select @numMaintenanceCompleted=ISNULL(SUM(case when O.TRAINING_STATE=1 then 1 else 0 end),0)
        , @numMaintenanceNotCompleted=ISNULL(SUM(case when O.TRAINING_STATE is null then 1 else 0 end),0)
    from COM_TRAINING_MAINTENANCE O
    where O.TRAININGID=@trainingID

    select @skillNumOperations=case 
                                when ISNULL(T.TRAINING_TYPE,1)=1 THEN S.ITERATIONS  --first training
                                else S.ITERATIONS_REPEAT --repeat training
                                end, 
        @skillId=T.SKILLID 
    from COM_TRAINING T 
        join COM_SKILLS S on T.SKILLID=S.ID
    where T.ID=@trainingID

    if @mode = 1
    begin
        if @numOperationsCompleted + @numPreparatoryCompleted + @numMaintenanceCompleted +
            @numOperationsNotCompleted + @numPreparatoryNotCompleted + @numMaintenanceNotCompleted
                =@skillNumOperations
            set @ret = 1
    end

    if @mode = 2
    begin
        if @numOperationsCompleted + @numPreparatoryCompleted + @numMaintenanceCompleted 
                =@skillNumOperations
            set @ret = 1
    end

    return @ret

end