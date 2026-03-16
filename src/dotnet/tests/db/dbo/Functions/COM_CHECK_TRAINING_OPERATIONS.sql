CREATE FUNCTION [dbo].[COM_CHECK_TRAINING_OPERATIONS]
(
    @trainingID int
)
RETURNS nvarchar(500)
AS
BEGIN
    
    declare @ret nvarchar(500)
    set @ret = ''

    declare @numOperations int, @skillNumOperations int, @skillId int, @numPreparatory int, @numMaintenance int

    select @skillId = SKILLID 
        from COM_TRAINING T
        where ID=@trainingID

    select @numOperations=count(*)
    from COM_TRAINING_OPERATIONS O
    where O.TRAININGID=@trainingID and O.MAPOPER_ID is not null

    select @numPreparatory = count(*)
    from COM_TRAINING_PREPARATORY O
    where O.TRAINING_ID=@trainingID 

    select @numMaintenance = count(*)
    from COM_TRAINING_MAINTENANCE O
    where O.TRAININGID=@trainingID 
    
    --check if operations have the same skill
    if @numOperations>0 and @skillID not in(
        select S.SKILLID
            from COM_TRAINING_OPERATIONS O
                join PR_MAP_OPER M on O.MAPOPER_ID=M.ID
                join PR_OPERATIONS OPS on M.OPERID=OPS.ID
                join COM_OPERATION_SKILL S on OPS.ID=S.OPERFORM_ID
            where O.TRAININGID=@trainingID
        union
        select S.SKILLID
            from COM_TRAINING_OPERATIONS O
                join PR_MAP_OPER M on O.MAPOPER_ID=M.ID
                join PR_OPERATIONS OPS on M.OPERID=OPS.ID
                join PR_OPERATIONS_GR G on OPS.OPERGRID=G.ID
                join COM_OPERATION_GROUP_SKILL S on G.ID=S.OPERGROUP_ID
            where O.TRAININGID=@trainingID
        union
        select S.SKILLID
            from COM_TRAINING_OPERATIONS O
                join PR_OPERATIONS OPS on O.OPERTYPEID=OPS.ID
                join COM_OPERATION_SKILL S on OPS.ID=S.OPERFORM_ID
            where O.TRAININGID=@trainingID
        union
        select S.SKILLID
            from COM_TRAINING_OPERATIONS O
                join PR_OPERATIONS OPS on O.OPERTYPEID=OPS.ID
                join PR_OPERATIONS_GR G on OPS.OPERGRID=G.ID
                join COM_OPERATION_GROUP_SKILL S on G.ID=S.OPERGROUP_ID
            where O.TRAININGID=@trainingID
        union
        select S.SKILLID
            from COM_TRAINING_OPERATIONS O
                join PR_OPERATION OP on O.OPERID=OP.ID
                join PR_OPERATIONS OPS on OP.OPERTYPEID=OPS.ID
                join COM_OPERATION_SKILL S on OPS.ID=S.OPERFORM_ID
            where O.TRAININGID=@trainingID
        union
        select S.SKILLID
            from COM_TRAINING_OPERATIONS O
                join PR_OPERATION OP on O.OPERID=OP.ID
                join PR_OPERATIONS OPS on OP.OPERTYPEID=OPS.ID
                join PR_OPERATIONS_GR G on OPS.OPERGRID=G.ID
                join COM_OPERATION_GROUP_SKILL S on G.ID=S.OPERGROUP_ID
            where O.TRAININGID=@trainingID
         )
        set @ret = @ret + 'Specified operations don''t require this skill. ' 
        
    --check if preparatory operations have the same skill
    if @numPreparatory>0 and @skillID not in(
        select S.SKILLID
            from COM_TRAINING_PREPARATORY O
                join PR_PREPARATORY P on O.PREPARATORY_ID=P.ID
                join PR_OPERATIONS OPS on P.OPERID=OPS.ID
                join COM_OPERATION_SKILL S on OPS.ID=S.OPERFORM_ID
            where O.TRAINING_ID=@trainingID
        union
        select S.SKILLID
            from COM_TRAINING_PREPARATORY O
                join PR_PREPARATORY P on O.PREPARATORY_ID=P.ID
                join PR_OPERATIONS OPS on P.OPERID=OPS.ID
                join PR_OPERATIONS_GR G on OPS.OPERGRID=G.ID
                join COM_OPERATION_GROUP_SKILL S on G.ID=S.OPERGROUP_ID
            where O.TRAINING_ID=@trainingID
         )
        set @ret = @ret + 'Specified preparatory operations don''t require this skill. ' 
        
    --check if maintenance operations have the same skill
    if @numMaintenance>0 and @skillID not in(
        select S.SKILLID
            from COM_TRAINING_MAINTENANCE O
                join PR_OPERATIONS OPS on O.OPERFORM_ID=OPS.ID
                join COM_OPERATION_SKILL S on OPS.ID=S.OPERFORM_ID
            where O.TRAININGID=@trainingID
        union
        select S.SKILLID
            from COM_TRAINING_MAINTENANCE O
                join PR_OPERATIONS OPS on O.OPERFORM_ID=OPS.ID
                join PR_OPERATIONS_GR G on OPS.OPERGRID=G.ID
                join COM_OPERATION_GROUP_SKILL S on G.ID=S.OPERGROUP_ID
            where O.TRAININGID=@trainingID
         )
        set @ret = @ret + 'Specified maintenance operations don''t require this skill. ' 

    if exists(
        select O1.ID
            from COM_TRAINING_OPERATIONS O1
                join COM_TRAINING_OPERATIONS O2 on O1.MAPOPER_ID=O2.MAPOPER_ID and O1.TRAININGID=@trainingID and O1.DEVICE_ID=O2.DEVICE_ID
                join COM_TRAINING T1 on O1.TRAININGID=T1.ID
                join COM_TRAINING T2 on O2.TRAININGID=T2.ID
            where T1.EMPLOYEEID<>T2.EMPLOYEEID)
        set @ret = @ret + 'These operations are used in a training for another employee.' 

    return @ret
END