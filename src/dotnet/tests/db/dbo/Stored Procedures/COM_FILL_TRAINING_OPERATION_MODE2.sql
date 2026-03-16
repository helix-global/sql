-- #AZURE06081:2025-11-25: Added call tracing.
CREATE PROCEDURE [dbo].[COM_FILL_TRAINING_OPERATION_MODE2]
    @operId int, @userId int,@ScopeGroup nvarchar(max) = null
AS
BEGIN
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[COM_FILL_TRAINING_OPERATION_MODE2]' [@ScopeName]
      ,(select
           @operId [OperID]
          ,@userId [UserID]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)

  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[COM_FILL_TRAINING_OPERATION_MODE2]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    declare @operMode int

    select @operMode = isnull(D.TRAINING_OPERATION_MODE,1)
        from COM_DEPARTMENTS D
        where D.ID = dbo.COM_USER_DEPARTMENT(@userId)

    if @operMode<>2
    begin
      exec [trace].[SPTraceLeave] @ScopeName=N'{code:{c1d2cf71-2118-42ea-82e9-00b6a12084c0}}'
      return
    end

    declare @operTypeId int

    select @operTypeId=O.OPERTYPEID
        from PR_OPERATION O with (nolock)
        where O.ID=@operId

    declare @opers table (ID int)
    declare @skills table (ID int)

    insert into @skills (ID)
    select S.SKILLID
        from COM_OPERATION_SKILL S
        where S.OPERFORM_ID=@operTypeId

    insert into @skills (ID)
    select S.SKILLID
        from COM_OPERATION_GROUP_SKILL S
            join PR_OPERATIONS O on S.OPERGROUP_ID=O.OPERGRID
        where O.ID=@operTypeId

    insert into @opers (ID)
    select MIN(O.ID)
        from COM_TRAINING_OPERATIONS O
            join COM_TRAINING T on O.TRAININGID=T.ID
        where T.EMPLOYEEID=dbo.DEF_EMPLOYEE(@userId) and T.S_S=4760002
                and O.OPERTYPEID=@operTypeId and T.OPERATION_MODE=2
                and O.OPERID is null
        group by O.TRAININGID

    update COM_TRAINING_OPERATIONS set OPERID=@operId
        where ID in(select ID from @opers)

    /*KB3040 иначе создавалась следующая операция без утверждения тренером*/
    update PR_OPERATION set
      USERINTRAINING=@userId
    where ID=@operId

    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{f065b5ed-28b8-477f-beae-f8ae2cb7928c}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[COM_FILL_TRAINING_OPERATION_MODE2]' [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{def1cf68-c56a-4446-af71-11af424ffc2d}}';
    throw;
  end catch

END