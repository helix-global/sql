




CREATE view [dbo].[COM_OPERATIONS_IN_TRAINING]
AS

    select O.ID * 3 as ID
            , T.SKILLID
            , T.EMPLOYEEID
            , OP.DEVICEID
            , D.MODELID
            , OP.EQID
            , NULL as EQMODELID
            , O.TRAINER_ID
            , O.GID
            , O.S_CDT
            , O.S_CR
            , O.S_MDT
            , O.S_MR
            , 'Item Operation' as TRAINING_OPERTYPE
            , OP.OPERTYPEID 
            , O.OPERID
            , O.TRAINING_STATE
        from COM_TRAINING_OPERATIONS O with (nolock)
            join COM_TRAINING T with (nolock) on O.TRAININGID=T.ID
            join PR_OPERATION OP with (nolock) on O.OPERID=OP.ID
            join PR_DEVICE D with (nolock) on OP.DEVICEID=D.ID
        where OP.S_S=1000013 and O.TRAINING_STATE is null 
    union
    select O.ID * 3 + 1 as ID
            , T.SKILLID
            , T.EMPLOYEEID
            , OP.DEVICEID
            , NULL as MODELID
            , OP.EQID
            , NULL as EQMODELID
            , O.TRAINER_ID
            , O.GID
            , O.S_CDT
            , O.S_CR
            , O.S_MDT
            , O.S_MR
            , 'Preparatory Operation' as TRAINING_OPERTYPE
            , OP.OPERTYPEID 
            , O.OPERID
            , O.TRAINING_STATE
        from COM_TRAINING_PREPARATORY O with (nolock)
            join COM_TRAINING T with (nolock) on O.TRAINING_ID=T.ID
            join PR_OPERATION OP with (nolock) on O.OPERID=OP.ID
        where OP.S_S=1000013 and O.TRAINING_STATE is null
    union
    select O.ID * 3 + 2 as ID
            , T.SKILLID
            , T.EMPLOYEEID
            , OP.DEVICEID
            , NULL as MODELID
            , OP.EQID
            , E.EQMODELID
            , O.TRAINER_ID
            , O.GID
            , O.S_CDT
            , O.S_CR
            , O.S_MDT
            , O.S_MR
            , 'Maintenance Operation' as TRAINING_OPERTYPE
            , OP.OPERTYPEID 
            , O.OPERID
            , O.TRAINING_STATE
        from COM_TRAINING_MAINTENANCE O with (nolock)
            join COM_TRAINING T with (nolock) on O.TRAININGID=T.ID
            join PR_OPERATION OP with (nolock) on O.OPERID=OP.ID
            join EQ_EQUIPMENT E with (nolock) on OP.EQID=E.ID
        where OP.S_S=1000013 and O.TRAINING_STATE is null