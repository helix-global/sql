-- KB5351:2025-06-17: Updated [PR_NEXT_OPERATION4] call to pass a parameter in the form "@name = value".
-- #AZURE06081:2025-11-25: Added call tracing.
CREATE procedure [dbo].[PR_NEXT_OPERATION] @DeviceID int,@DoneOperID int,@ScopeGroup nvarchar(max)=null
as
begin
  set nocount on
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[PR_NEXT_OPERATION]'    [@ScopeName]
      ,(select
          @DeviceID   [DeviceID]
        ,@DoneOperID [DoneOperID]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)

  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[PR_NEXT_OPERATION]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    /*exec PR_NEXT_OPERATION_OLD @DeviceID , @DoneOperID*/
    exec [dbo].[PR_NEXT_OPERATION4] @DeviceID=@DeviceID,@DoneOperID=@DoneOperID,@ScopeGroup=@ScopeGroup
    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{27f13740-a075-4545-a6ba-d6d22f3a9b4f}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[PR_NEXT_OPERATION]'    [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{e418450a-612f-4d70-a448-5f321aa9ed90}}';
    throw;
  end catch
  set nocount off
end