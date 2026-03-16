-- #AZURE06081:2025-11-25: Added call tracing.
CREATE PROCEDURE [dbo].[COM_SET_TRAINING_COMPLETE]
(@operID int, @userID int,@ScopeGroup nvarchar(max) = null)
AS
BEGIN
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[COM_SET_TRAINING_COMPLETE]'   [@ScopeName]
      ,(select
         @operID [OperID]
        ,@userID [UserID]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)

  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[COM_SET_TRAINING_COMPLETE]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    declare @isPreparatory bit = 0
    declare @trainingID int, @needsApproval int

    declare @trainingIds table (ID int, NEEDS_APPROVAL int)

    insert into @trainingIds(ID, NEEDS_APPROVAL)
    select distinct O.TRAININGID, NEEDS_APPROVAL
        from COM_TRAINING_OPERATIONS O
            join COM_TRAINING T on O.TRAININGID=T.ID
            join COM_SKILLS S on T.SKILLID=S.ID
            left join (select top 1 P.TRAININGID 
                            from COM_TRAINING_OPERATIONS P with (nolock) 
                                join PR_OPERATION O with (nolock) on P.OPERID=O.ID
								join COM_TRAINING T on P.TRAININGID=T.ID --есть незавершенные операции или завершенные не сотрудником из тренинга
                            where O.S_S<>1000013 or (O.S_S=1000013 and dbo.DEF_EMPLOYEE(O.S_MR)<>T.EMPLOYEEID) ) P  on T.ID=P.TRAININGID
        where O.OPERID=@operID and P.TRAININGID is null
            and dbo.COM_CHECK_TRAINING_OPERATIONS_NUMBER(T.ID,2)=1 --достигнуто нужное количество операций
    
    insert into @trainingIds(ID, NEEDS_APPROVAL)        
    select distinct O.TRAINING_ID, S.NEEDS_APPROVAL
        from COM_TRAINING_PREPARATORY O
            join COM_TRAINING T on O.TRAINING_ID=T.ID
            join COM_SKILLS S on T.SKILLID=S.ID
            left join (select top 1 P.TRAINING_ID 
                            from COM_TRAINING_PREPARATORY P with (nolock) 
                                join PR_OPERATION O with (nolock) on P.OPERID=O.ID
								join COM_TRAINING T on P.TRAINING_ID=T.ID --есть незавершенные операции или завершенные не сотрудником из тренинга
                            where O.S_S<>1000013 or (O.S_S=1000013 and dbo.DEF_EMPLOYEE(O.S_MR)<>T.EMPLOYEEID) ) P  on T.ID=P.TRAINING_ID
        where O.OPERID=@operID and P.TRAINING_ID is null and O.TRAINING_ID not in (select ID from @trainingIds)
            and dbo.COM_CHECK_TRAINING_OPERATIONS_NUMBER(T.ID,2)=1 --достигнуто нужное количество операций
    
    insert into @trainingIds(ID, NEEDS_APPROVAL)        
    select distinct O.TRAININGID, S.NEEDS_APPROVAL
        from COM_TRAINING_MAINTENANCE O
            join COM_TRAINING T on O.TRAININGID=T.ID
            join COM_SKILLS S on T.SKILLID=S.ID
            left join (select top 1 P.TRAININGID 
                            from COM_TRAINING_MAINTENANCE P with (nolock) 
                                join PR_OPERATION O with (nolock) on P.OPERID=O.ID
								join COM_TRAINING T on P.TRAININGID=T.ID --есть незавершенные операции или завершенные не сотрудником из тренинга
                            where O.S_S<>1000013 or (O.S_S=1000013 and dbo.DEF_EMPLOYEE(O.S_MR)<>T.EMPLOYEEID) ) P  on T.ID=P.TRAININGID
        where O.OPERID=@operID and P.TRAININGID is null and O.TRAININGID not in (select ID from @trainingIds)
            and dbo.COM_CHECK_TRAINING_OPERATIONS_NUMBER(T.ID,2)=1 --достигнуто нужное количество операций

    if not exists(select * from @trainingIds) return

    declare cur_COM_SET_TRAINING_COMPLETE cursor for 
    select ID, NEEDS_APPROVAL
    from @trainingIds
                    
    OPEN cur_COM_SET_TRAINING_COMPLETE

    FETCH NEXT FROM cur_COM_SET_TRAINING_COMPLETE INTO @trainingID, @needsApproval

    WHILE @@FETCH_STATUS=0
    BEGIN
        
        if @needsApproval=1
         begin
            update COM_TRAINING set S_S=4760003 --complete
                where ID=@trainingID
         end
         else
         begin
            update COM_TRAINING set S_S=4760004 --approved
                where ID=@trainingID

            exec COM_ADD_SKILL_TO_EMPLOYEE @trainingID, @userID
         end
    
        FETCH NEXT FROM cur_COM_SET_TRAINING_COMPLETE INTO @trainingID, @needsApproval
    END

    CLOSE cur_COM_SET_TRAINING_COMPLETE
    DEALLOCATE cur_COM_SET_TRAINING_COMPLETE
    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{5cd14b09-fcc6-4990-b142-1b4c8832771e}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[COM_SET_TRAINING_COMPLETE]'   [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{496d88b3-dfe2-4720-a1dc-646c206ee0d8}}';
    throw;
  end catch

END