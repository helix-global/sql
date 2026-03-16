/*
  KB5199 - Auto change status for fully completed / canceled IoE trainings

  Test: exec [dbo].[IOE_KB5199STATESCHANGE] 1620 /* IPGL-PDB-Agent */
*/
create PROCEDURE [dbo].[IOE_KB5199STATESCHANGE]
  @UserID int,
  @aMode int = null
AS
BEGIN
  set nocount on

  -- Class states for ioe_training (Assigned Courses): 2130062 Completed, 7290001 Canceled
  -- Class states for ioe_employee_progress:           2130064 Completed, 1000208 Canceled

  declare @now datetime = GetDate();
  declare @logEventType int = 30064; /* Item_Mass_Changes_Exec */
  declare @docOID int = 2130089; /* ioe_training */

  -- Rows in ioe_training which might need to be updated.
  declare @trainingCompletionInfo table ([TRAININGID] int, [CompletedCount] int, [CanceledCount] int, [TotalCount] int);
  
  insert into
    @trainingCompletionInfo
  select
    progress.[TRAININGID],
    sum(case when progress.[S_S] = 2130064 /* Completed */ then 1 else 0 end) as [CompletedCount],
    sum(case when progress.[S_S] = 1000208 /* Canceled */ then 1 else 0 end) as [CanceledCount],
    count(*) as [TotalCount]
  from
    [dbo].[IOE_PROGRESS] progress (nolock)
    join [dbo].[IOE_TRAINING] training (nolock) on progress.[TRAININGID] = training.[ID]
  where
    training.[S_S] != 2130062 /* Completed */ and training.[S_S] != 7290001 /* Canceled */
  group by
    progress.[TRAININGID];

  -- debug
  --select * from @trainingCompletionInfo

  update tr
  set
    tr.[S_S] = case when tci.TotalCount = tci.CanceledCount then 7290001 /* Canceled */
                    when tci.TotalCount = tci.CanceledCount + tci.CompletedCount then 2130062 /* Completed */
                    else tr.[S_S] end,
    [S_MR] = @UserID,
    [S_MDT] = @now
  from
    [dbo].[IOE_TRAINING] tr
    join @trainingCompletionInfo tci on tr.[ID] = tci.[TRAININGID]
  where
    tci.TotalCount > 0 and (tci.TotalCount = tci.CanceledCount or tci.TotalCount = tci.CanceledCount + tci.CompletedCount);

  insert into [dbo].[DEF_LOG] ([DD], [LEV], [CAPTION], [S_USERID], [EV_TYPE], [DOCOID], [DOCID])
  select
    @now,
    1 /* Info */,
    'Status changed automatically to ' + case when tci.TotalCount = tci.CanceledCount then '''Canceled'' (7290001)'
                                              when tci.TotalCount = tci.CanceledCount + tci.CompletedCount then '''Completed'' (2130062)'
                                              else '''NOT_CHANGED''' end,
    @UserID,
    @logEventType,
    @docOID,
    tci.[TRAININGID]
  from
    @trainingCompletionInfo tci
  where
    tci.TotalCount > 0 and (tci.TotalCount = tci.CanceledCount or tci.TotalCount = tci.CanceledCount + tci.CompletedCount);
  
  set nocount off
END