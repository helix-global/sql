-- #AZURE06081:2025-11-25: Added call tracing.
CREATE procedure [dbo].[COM_FILL_TRANING_OPERATIONS]
    @trainingID int,@ScopeGroup nvarchar(max) = null
AS
begin
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[COM_FILL_TRANING_OPERATIONS]'[@ScopeName]
      ,(select
         @trainingID [TrainingID]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)

  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[COM_FILL_TRANING_OPERATIONS]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    declare @operations table (ID int)
    declare @id int, @operMode int, @autoinclude int
    declare @operCount int

    select @operMode=T.OPERATION_MODE, @autoinclude=isnull(T.AUTOINCLUDE_ITEM,0)
        from COM_TRAINING T
        where T.ID=@trainingID

    if isnull(@operMode,1)<>1
    begin
      exec [trace].[SPTraceLeave] @ScopeName=N'{code:{0d32c3d9-904f-46a2-9b55-e554d28e821a}}'
      return
    end

    insert into @operations (ID)
    select O.ID 
    from PR_OPERATION O with (nolock)
        join PR_MAP_OPER M on O.REVOPERID=M.ID
        join COM_TRAINING_OPERATIONS T on T.MAPOPER_ID = M.ID and O.DEVICEID=T.DEVICE_ID
    where T.TRAININGID=@trainingID and T.TRAINING_STATE is null
          --  and O.ID not in(select OPERID from COM_TRAINING_OPERATIONS) 

    if @autoinclude=1
    begin

        select @operCount = COUNT(T.ID)
            from COM_TRAINING_OPERATIONS T
            where T.TRAININGID=@trainingID and T.TRAINING_STATE is null 
                    and T.DEVICE_ID is null and T.MAPOPER_ID is not null 
                    and T.REVISIONID is not null

        insert into @operations (ID)
        select top (@operCount) O.ID 
        from PR_OPERATION O with (nolock)
            join PR_MAP_OPER M on O.REVOPERID=M.ID
            join PR_DEVICE D on O.DEVICEID=D.ID
            join COM_TRAINING_OPERATIONS T on T.MAPOPER_ID = M.ID and T.REVISIONID=D.REVID and T.DEVICE_ID is null
        where T.TRAININGID=@trainingID and T.TRAINING_STATE is null and O.S_S=1000032 
            and not exists( select OPERID from COM_TRAINING_OPERATIONS where OPERID=O.ID) 

    end
    
    insert into @operations (ID)
    select T.OPERID
    from COM_TRAINING_OPERATIONS T 
    where T.TRAININGID=@trainingID and T.TRAINING_STATE is null and T.MAPOPER_ID is null 
        and T.OPERID is not null

   /* 
    insert into @operations (ID)
    select top 1 O.ID 
    from PR_OPERATION O with (nolock)
        join PR_PREPARATORY PR on PR.OPERID=O.OPERTYPEID
        join COM_TRAINING_PREPARATORY TP on TP.PREPARATORY_ID=PR.ID
    where TP.TRAINING_ID=@trainingID 
        and O.S_S=1000032 --pending
        and O.USERINTRAINING is null and TP.TRAINING_STATE is null
    */

    insert into @operations (ID)
    select P.OPERID
    from COM_TRAINING_PREPARATORY P
    where P.TRAINING_ID=@trainingID 
        and P.OPERID is not null

    insert into @operations (ID)
    select top 1 O.ID 
    from PR_OPERATION O with (nolock)
        join COM_TRAINING_MAINTENANCE M on M.OPERFORM_ID=O.OPERTYPEID and O.EQID=M.EQID
    where M.TRAININGID=@trainingID 
        and O.S_S=1000032 --pending
        and O.USERINTRAINING is null and M.TRAINING_STATE is null
/*
    select o.*, OP.S_S, D.SN 
        from @operations o
            join PR_OPERATION OP on o.ID=OP.ID
            join PR_DEVICE D on OP.DEVICEID=D.ID
*/
    select top 1 @id = ID from @operations
    while @id is not null
    begin
      begin try
        exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{d2abb6e8-4d56-4e0a-954b-3f7abb56f6bd}}'
        exec [dbo].[COM_FILL_TRAINING_OPERATION] @id,@ScopeGroup=@ScopeGroup
        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{af40117c-d90f-4881-a704-3142f1104353}}'
      end try
      begin catch
        exec [trace].[SPTraceLeave] @ScopeName=N'{code:{dbe51f2e-34ff-4d4b-8396-0d38aa467667}}';
        throw;
      end catch

      
      delete from @operations where ID=@id
      set @id = null
      select top 1 @id = ID from @operations
    end
    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{89e32da7-767a-4d8c-a3fb-4f2f563b25a7}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[COM_FILL_TRANING_OPERATIONS]' [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{cb394eaf-71fa-4f88-9f01-1d18bf7bd93e}}';
    throw;
  end catch
end