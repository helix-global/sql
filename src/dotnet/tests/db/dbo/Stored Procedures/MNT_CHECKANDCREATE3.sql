--#AZURE06081:2025-11-25: Added call tracing.
--KB4896:2024-07-23: Added optional parameter.
--KB4452:2024-02-14: Updated to use [dbo].[MNT_NEXT_SNOOZE4] and [dbo].[MNT_PLAN_NEXTDATE_SHIFT_MODE].
--                   Logging operation creation events. Refactoring.
CREATE procedure [dbo].[MNT_CHECKANDCREATE3] (@PlanID int,@Options nvarchar(max)=null,@ScopeGroup nvarchar(max) = null)
as
begin
  declare @ScopeContext xml=(
    select top 1
       isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
      ,N'[dbo].[MNT_CHECKANDCREATE3]'   [@ScopeName]
      ,(select
         @PlanID  [PlanID]
        ,@Options [Options]
      for xml path('ScopeContext.Parameters'),type,elements xsinil)
    for xml path('ScopeContext'),elements)

  exec [trace].[SPTraceEnter] @ScopeName=N'[dbo].[MNT_CHECKANDCREATE3]',@ScopeContext=@ScopeContext,@ScopeGroup=@ScopeGroup
  begin try
    --if @PlanID is null return
    declare @UserID int = [dbo].[DEF_USERID]()
    exec [dbo].[MNT_CHECKANDCREATE4] @PlanID,@UserID,@Options,@ScopeGroup=@ScopeGroup
    exec [trace].[SPTraceLeave] @ScopeName=N'{code:{847f254d-97bb-49ce-ba5c-d60b7209bb9c}}'
  end try
  begin catch
    set @ScopeContext=(
      select top 1
         isnull(@ScopeGroup,N'{x:Null}') [@ScopeGroup]
        ,N'[dbo].[MNT_CHECKANDCREATE3]'   [@ScopeName]
        ,(select
           error_message()   [Message]
          ,error_number()    [Number]
          ,error_severity()  [Severity]
          ,error_state()     [State]
          ,error_line()      [Line]
          ,error_procedure() [Procedure]
        for xml path('ScopeContext.Exception'),type,elements xsinil)
      for xml path('ScopeContext'),elements)
    exec [trace].[SPTraceLeave] @ScopeContext=@ScopeContext,@ScopeName=N'{code:{e57f2bc1-f783-49d6-a842-e6c362005e4d}}';
    throw;
  end catch
end