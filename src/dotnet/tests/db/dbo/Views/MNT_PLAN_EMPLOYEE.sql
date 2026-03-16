--KB4896:2024-07-26: Should includes only actual employees for specified operation group.
--KB4896:2024-07-26: Initial update.
CREATE VIEW [dbo].[MNT_PLAN_EMPLOYEE]
AS
select
   row_number() over (order by [p].[ID]) [ID]
  ,[p].[ID] [MNT_PLAN_ID]
  ,[b].[ID] [OPERTYPEID]
  ,[e].[ID] [EMPLID]
  ,[u].[ID] [USERID]
  ,(select max([o].[COMPLETED_DT])
    from [dbo].[PR_OPERATION] [o] with(nolock)
    where [o].[OPERTYPEID]=[p].[OPERID]
      and [o].[MNT_PLANID]=[p].[ID]
      and coalesce([o].[USERINPROGRESS],[o].[FORCEUSERINPROGRESS],[o].[USERINTRAINING],[o].[S_MR])=[u].[ID]) [LASTDATE]
  ,[dbo].[MNT_NEXT_SNOOZE_EMP]([p].[ID],[e].[ID]) [NEXTDATE]
from [dbo].[MNT_PLAN] [p] with(nolock)
  inner join [dbo].[PR_OPERATIONS]     [b] with(nolock) on [b].[ID]=[p].[OPERID]
  inner join [dbo].[PR_EMPL_TO_OPERGR] [g] with(nolock) on [g].[GROUPID]=[b].[OPERGRID]
  inner join [dbo].[COM_EMPLOYEE]      [e] with(nolock) on [e].[ID]=[g].[EMPLOYEEID]
  inner join [dbo].[DEF_USERS]         [u] with(nolock) on [u].[EMPLOYEEID]=[e].[ID]
where [e].[S_S]=1
  and [p].[CRMODE]=2
  and ([g].[DEND] is null or [g].[DEND] >= getdate())