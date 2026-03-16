--KB4487:2024-02-13: Validates "No Skill Action" for "Operation Groups".
--KB4423:2023-11-29: Validates "No Skill Action" for "Operation Forms". Related to KB3076.
--KB3734:2022-12-13
--KB1852:2020-10-07
CREATE FUNCTION [dbo].[COM_CHECK_SKILL_AND_TRAINING]
(
    @OperID int, @UserID int
)
RETURNS
@ret TABLE
(
    CODE int, ERR_TEXT nvarchar(4000)
)
AS
BEGIN
--проверка на тренинги и наличие навыков

    declare @hasSkills bit, @isInTraining bit
    set @hasSkills=0
    set @isInTraining=0

    declare @curDate datetime 
    set @curDate = getdate()

    declare @tRequiredSkills table (ID int)

    insert into @tRequiredSkills (ID)
     select S.SKILLID
                    from PR_OPERATION O with (nolock)
                    join PR_OPERATIONS OPS with (nolock) on O.OPERTYPEID=OPS.ID
                    join PR_OPERATIONS_GR G with (nolock) on OPS.OPERGRID=G.ID
                    join COM_OPERATION_GROUP_SKILL S with (nolock) on G.ID=S.OPERGROUP_ID
                        where O.ID=@OperID and S.MODELID is null
    union   
     select S.SKILLID
                    from PR_OPERATION O with (nolock)
                    join PR_OPERATIONS OPS with (nolock) on O.OPERTYPEID=OPS.ID
                    join PR_OPERATIONS_GR G with (nolock) on OPS.OPERGRID=G.ID
                    join COM_OPERATION_GROUP_SKILL S with (nolock) on G.ID=S.OPERGROUP_ID
                    join PR_DEVICE D with (nolock) on O.DEVICEID=D.ID
                        where O.ID=@OperID and S.MODELID=D.MODELID
    union
    select S.SKILLID
                    from PR_OPERATION O with (nolock)
                    join PR_OPERATIONS OPS with (nolock) on O.OPERTYPEID=OPS.ID
                    join COM_OPERATION_SKILL S with (nolock) on OPS.ID=S.OPERFORM_ID
                        where O.ID=@OperID and S.MODELID is null
    union
    select S.SKILLID
                    from PR_OPERATION O with (nolock)
                    join PR_OPERATIONS OPS with (nolock) on O.OPERTYPEID=OPS.ID
                    join COM_OPERATION_SKILL S with (nolock) on OPS.ID=S.OPERFORM_ID
                    join PR_DEVICE D with (nolock) on O.DEVICEID=D.ID
                        where O.ID=@OperID and S.MODELID=D.MODELID


    if exists(select * from @tRequiredSkills)
    begin
        if not exists(
                select S.ID
                    from @tRequiredSkills S
                                        left join 
                            (select D.SKILLID
                                from COM_EMPLOYEE_SKILL_EXPIRATION_DATES D with (nolock)
                                        where D.USERID=@UserID and D.EXPIRATION_DATE>@curDate) E on S.ID=E.SKILLID
                        where E.SKILLID is null)
            set @hasSkills=1
    
        if exists(select O.ID 
                    from PR_OPERATION O with (nolock)
                        join COM_TRAINING_OPERATIONS T with (nolock) on O.REVOPERID=T.MAPOPER_ID and O.DEVICEID=T.DEVICE_ID
                        join COM_TRAINING TR with (nolock) on T.TRAININGID=TR.ID
                        join DEF_USERS U with (nolock) on TR.EMPLOYEEID=U.EMPLOYEEID
                    where O.ID=@OperID and TR.S_S not in(4760003, 4760004, 4760005) and U.ID=@UserID)
            set @isInTraining=1

        /*KB3734*/
        if exists(select O.ID 
                    from PR_OPERATION O with (nolock)
                        join COM_TRAINING_PREPARATORY T with (nolock) on T.OPERID = O.ID
                        join COM_TRAINING TR with (nolock) on T.TRAINING_ID=TR.ID
                        join DEF_USERS U with (nolock) on TR.EMPLOYEEID=U.EMPLOYEEID
                    where O.ID=@OperID and TR.S_S not in(4760003, 4760004, 4760005) and U.ID=@UserID)
            set @isInTraining=1


        if @hasSkills=0
        begin
            if @isInTraining=0
            begin
                declare @tMissingSkills table (SKILLNAME nvarchar(250))

                insert into @tMissingSkills (SKILLNAME)
                select S.NAME
                from COM_SKILLS S with (nolock)
                /*KB1852>  left join (select SKILLID from COM_EMPLOYEE_SKILL E where E.EMPLOYEEID=dbo.DEF_EMPLOYEE(@UserID)) E on S.ID=E.SKILLID*/
                left join (select D.SKILLID
                             from COM_EMPLOYEE_SKILL_EXPIRATION_DATES D with (nolock)
                            where D.USERID=@UserID 
                              and D.EXPIRATION_DATE>@curDate) E on S.ID=E.SKILLID
                /* <KB1852 */                        
                where S.ID in (select ID from @tRequiredSkills) and E.SKILLID is null

                declare @sNames nvarchar(4000) = ''

                if exists (select * from @tMissingSkills)
                begin
                  select @sNames = @sNames + '"' + s.SKILLNAME + '", '
                  from @tMissingSkills s
  
                  set @sNames = SUBSTRING(@sNames,1,len(@sNames)-1)
                end

        declare @HasError int = 0
        /*KB4423 =>*/
        -- if there is "No skill action= error" on the deparatment settings 
        -- and if there is a training plan in the "In Progress" status, 
        -- the operator specified in this plan could start operations for training (specified in the plan) 
        -- with a warning about the lack of a skill.
        if exists(select o.ID
                  from [dbo].PR_OPERATION o with(nolock)
                    inner join [dbo].COM_OPERATION_SKILL [S] with(nolock) on S.OPERFORM_ID = o.OPERTYPEID --skill id из операции
                    inner join [dbo].COM_TRAINING        [T] with(nolock) on T.SKILLID = S.SKILLID -- trainings по найденному скилу
                    inner join [dbo].DEF_USERS           [U] with(nolock) on T.EMPLOYEEID = U.EMPLOYEEID 
                    inner join [dbo].COM_EMPLOYEE        [E] with(nolock) on U.EMPLOYEEID = E.ID
                    inner join [dbo].COM_DEPARTMENTS     [D] with(nolock) on D.ID = E.DEPID -- для проверка настройки NO_SKILL_ACTION у департамента
                  where o.ID = @OperID
                    and U.ID = @UserID
                    and T.S_S = 4760002 /* In training */
                    and D.NO_SKILL_ACTION = 1)
        begin
          -- CODE 100 will be checked in [dbo].[PR_CHECK_OR_NOTIFY_STARTED]  
          insert into @ret (CODE, ERR_TEXT) values (100, 'You don''t have required skills to start this operation: ' + @sNames)
          set @HasError = 1
        end

        --KB4487
        if (@HasError = 0) and exists(select [o].[ID]
                  from [dbo].[PR_OPERATION] [o] with(nolock)
                    inner join [dbo].[PR_OPERATIONS]             [O] with(nolock) on [O].[ID]=[o].[OPERTYPEID]
                    inner join [dbo].[COM_OPERATION_GROUP_SKILL] [S] with(nolock) on [S].[OPERGROUP_ID] = [O].[OPERGRID] --skill id from operation group
                    inner join [dbo].[COM_TRAINING]              [T] with(nolock) on [T].[SKILLID] = [S].[SKILLID] -- trainings по найденному скилу
                    inner join [dbo].[DEF_USERS]                 [U] with(nolock) on [T].[EMPLOYEEID] = [U].[EMPLOYEEID]
                    inner join [dbo].[COM_EMPLOYEE]              [E] with(nolock) on [U].[EMPLOYEEID] = [E].[ID]
                    inner join [dbo].[COM_DEPARTMENTS]           [D] with(nolock) on [D].[ID] = [E].[DEPID] -- для проверка настройки NO_SKILL_ACTION у департамента
                  where [o].[ID] = @OperID
                    and [U].[ID] = @UserID
                    and [T].[S_S] = 4760002 /* In training */
                    and [D].[NO_SKILL_ACTION] = 1)
        begin
          insert into @ret (CODE, ERR_TEXT) values (100, 'You don''t have required skills to start this operation: ' + @sNames + '. Skills required by Operation Group option {No Skill Action}.')
          set @HasError = 1
        end
        if @HasError = 0
          /*<= KB4423*/
          insert into @ret (CODE, ERR_TEXT) values (1, 'You don''t have required skills to start this operation: ' + @sNames)
        end
      end
    end

    declare @employeeName nvarchar(200)
    select @employeeName = E.NAME
            from PR_OPERATION O with (nolock)
                join COM_TRAINING_OPERATIONS T with (nolock) on O.REVOPERID=T.MAPOPER_ID and O.DEVICEID=T.DEVICE_ID
                join COM_TRAINING TR with (nolock) on T.TRAININGID=TR.ID
                join COM_EMPLOYEE E with (nolock) on TR.EMPLOYEEID=E.ID
                join DEF_USERS U with (nolock) on U.EMPLOYEEID=E.ID
            where O.ID=@OperID and TR.S_S not in(4760003, 4760004, 4760005) and U.ID<>@UserID
    if @employeeName is not null
    begin
        insert into @ret (CODE, ERR_TEXT) values (2, 'This operation should be started by another employee (' + @employeeName + ').')
    end

    if not exists(select * from @ret)
        insert into @ret (CODE, ERR_TEXT) values (0, NULL)

    RETURN
END