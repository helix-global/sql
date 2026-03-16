-- =============================================
-- Author:      Dmitrii Maistrenko
-- Create date: 2024-02-12
-- Description: "Employee Progress changed" event handler
-- =============================================
--+KB4672:2024-03-18:Commented tracing block. Incompatible with version prior 13.0.
--+KB4600:2024-02-12:Initial update.
CREATE procedure [dbo].[IOE_EMPLOYEE_PROGRESS_STATE_CHANGED]
   @UserID int
  ,@ContextID int
  ,@S_S_OLD int
  ,@S_S_NEW int
  ,@S_MR_NEW int
as
begin
  set nocount on
  declare @Trace int = 0

  /*
  -- KB4672
  if @Trace=1
  begin
    insert into [dbo].[DEF_LOG] ([DD],[LEV],[CAPTION],[S_USERID],[EV_TYPE],[DOCOID],[DOCID],[EV_TEXT])
        values (getdate(),1,'trace:{[dbo].[IOE_EMPLOYEE_PROGRESS_STATE_CHANGED]}',
            [dbo].[DEF_USERID](),-1,2130090,@ContextID,(
              select
                 @UserID [UserID]
                ,@ContextID [ContextID]
                ,cast(@S_S_OLD as varchar(max)) + '{' + (select top 1 [dbo].[DEF_STATE_NAME_U]([a].[OID],@UserID) from [dbo].[DEF_CLASS_STATES] [a] where [a].[OID]=@S_S_OLD) + '}' [S_S_OLD]
                ,cast(@S_S_NEW as varchar(max)) + '{' + (select top 1 [dbo].[DEF_STATE_NAME_U]([a].[OID],@UserID) from [dbo].[DEF_CLASS_STATES] [a] where [a].[OID]=@S_S_NEW) + '}' [S_S_NEW]
                ,@S_MR_NEW [S_MR_NEW]
                ,'exec [dbo].[IOE_EMPLOYEE_PROGRESS_STATE_CHANGED]'+
                    ' @UserID='    + isnull(cast(@UserID as varchar(max)),'null')    +
                    ',@ContextID=' + isnull(cast(@ContextID as varchar(max)),'null') +
                    ',@S_S_OLD='   + isnull(cast(@S_S_OLD as varchar(max)),'null')   +
                    ',@S_S_NEW='   + isnull(cast(@S_S_NEW as varchar(max)),'null')   +
                    ',@S_MR_NEW='  + isnull(cast(@S_MR_NEW as varchar(max)),'null') [SQL]
              for json path))
  end*/

  if (@S_S_OLD=2130063) and (@S_S_NEW = 1000208) --"In Progress"->"Canceled"
  begin
    delete from [dbo].[IOE_PROGRESS_T]
    where [VNESHID]=@ContextID
  end
end