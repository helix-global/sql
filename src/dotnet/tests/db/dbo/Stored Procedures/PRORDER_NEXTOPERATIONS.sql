-- #AZURE06081:2025-11-25: Added call tracing.
CREATE procedure [dbo].[PRORDER_NEXTOPERATIONS]
  @OrderID int,@ScopeGroup nvarchar(max) = null
as 
begin
  set nocount on
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}')   [@ScopeGroup]
      ,N'[dbo].[PRORDER_NEXTOPERATIONS]' [@ScopeName]
      ,(select
         @OrderID [OrderID]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)
  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[PRORDER_NEXTOPERATIONS]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    declare @deviceID int;
    declare @counter int

    -- Process Devices of models with OPERCRMODE is set
    begin
      declare @modelCounters table (ID int primary key, OPERCRMODE int)
      insert into @modelCounters
        select M.ID,M.OPERCRMODE 
        from PR_PRORDER O
          left join PR_PRORDER_T OT on O.ID = OT.PRORDERID
          left join PR_MODELS M on OT.MODELID = M.ID
        where O.ID = @OrderID
          and isnull(M.OPERCRMODE,0)>0

      declare modelsCur cursor local read_only for 
        select M.ID,M.OPERCRMODE 
        from PR_PRORDER O
          left join PR_PRORDER_T OT on O.ID = OT.PRORDERID
          left join PR_MODELS M on OT.MODELID = M.ID
        where O.ID = @OrderID
          and isnull(M.OPERCRMODE,0)>0

      declare @modelID int;
      open modelsCur;
      while 1=1
      begin
        fetch next from modelsCur into @modelID, @counter;
        if @@fetch_status<>0 
          break;
  
        declare deviceCur cursor local read_only for 
        select ID from PR_DEVICE where ORDERID = @OrderID and MODELID=@modelID;
        open deviceCur;
        while 1=1
        begin
          fetch next from deviceCur into @deviceID;
          if @@fetch_status<>0
            break;

          begin try
            exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{67ee386f-f744-4589-882c-58260b14927c}}'
            exec [dbo].[PR_NEXT_OPERATION] @deviceID, null,@ScopeGroup=@ScopeGroup;
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{9d72d270-587b-4afa-8ab0-c19d2fe6c3ad}}'
          end try
          begin catch
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{30819886-edbf-48fb-80bb-7553654ad3b3}}';
            throw;
          end catch

          select @counter=@counter-1
          if (@counter <= 0)
            break;
        end
        close deviceCur;
        deallocate deviceCur; 
      end
      close modelsCur;
      deallocate modelsCur;
    end

    -- Process Devices of model types with OPERCRMODE is set and models with OPERCRMODE is NOT set
    begin
      declare @modelTypeCounters table (ID int primary key, OPERCRMODE int)
      insert into @modelTypeCounters
        select distinct M.ID,M.OPERCRMODE 
        from PR_PRORDER O
          left join PR_PRORDER_T OT on O.ID = OT.PRORDERID
          left join PR_MODELS M on OT.MODELID = M.ID
          left join PR_MODELTYPE MT on M.TYPEID = MT.ID
        where O.ID = @OrderID
          and isnull(M.OPERCRMODE,0)=0
          and isnull(MT.OPERCRMODE,0)>0

      declare modelTypesCur cursor local read_only for 
      select ID, OPERCRMODE from @modelTypeCounters;
  
      declare @modelTypeID int;
      open modelTypesCur;
      while 1=1
      begin
        fetch next from modelTypesCur into @modelTypeID, @counter;
        if @@fetch_status<>0 
          break;
        declare deviceCur cursor local read_only for 
          select D.ID from PR_DEVICE D 
            left join PR_MODELS M on D.MODELID = M.ID 
          where D.ORDERID = @OrderID 
            and M.TYPEID=@modelTypeID 
            and M.ID not in (select ID from @modelCounters);
        open deviceCur;
        while 1=1
        begin
          fetch next from deviceCur into @deviceID;
          if @@fetch_status<>0 
            break;
          begin try
            exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{4d26a0fb-9350-4c22-a6ef-0684d782a2a1}}'
            exec [dbo].[PR_NEXT_OPERATION] @deviceID, null,@ScopeGroup=@ScopeGroup;
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{bad11592-8cb6-4eae-8e0e-64509ca68035}}'
          end try
          begin catch
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{a14c59be-50e5-45d1-add0-542518051ccf}}';
            throw;
          end catch

          select @counter=@counter-1
          if (@counter <= 0)
            break;
        end
        close deviceCur;
        deallocate deviceCur;
      end
      close modelTypesCur;
      deallocate modelTypesCur;
    end

    -- Process all other Devices where OPERCRMODE is NOT set
    begin
      declare deviceCur cursor local read_only for 
        select D.ID from PR_DEVICE D 
          left join PR_MODELS M on D.MODELID = M.ID 
        where D.ORDERID = @OrderID 
          and M.TYPEID not in (select ID from @modelTypeCounters)
          and M.ID not in (select ID from @modelCounters);
      open deviceCur;
      while 1=1
      begin
        fetch next from deviceCur into @deviceID;
        if @@fetch_status<>0 
          break;
          begin try
            exec [trace].[SPTraceEnter] @ScopeGroup=@ScopeGroup,@ScopeName=N'{code:{612b0932-b2df-4fdd-909e-f8c44fbb2ce8}}'
            exec [dbo].[PR_NEXT_OPERATION] @deviceID, null,@ScopeGroup=@ScopeGroup;
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{cd820862-5522-4f9a-b6b6-d9083f10d01f}}'
          end try
          begin catch
            exec [trace].[SPTraceLeave] @ScopeName=N'{code:{312a13d7-7bbf-43b0-808b-b356f7b87d17}}';
            throw;
          end catch
      end
      close deviceCur;
      deallocate deviceCur;
    end
    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{665bcf23-77da-4ca2-ac1d-2b4376f776c2}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}')   [@ScopeGroup]
        ,N'[dbo].[PRORDER_NEXTOPERATIONS]' [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{701b4030-2693-4320-ab0b-89510437d3ab}}';
    throw;
  end catch
  set nocount off
end