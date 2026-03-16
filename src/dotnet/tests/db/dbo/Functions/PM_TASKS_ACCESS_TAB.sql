
--KB5243:2025-02-24: The user should be able to see tasks that they have created themselves.
CREATE function [dbo].[PM_TASKS_ACCESS_TAB] (@UserID int,@Mode int,@Date datetime)
returns @res table ([ID] int primary key clustered)
as
begin

  /*
  1) HEAD&VICE видит все таски своего отдела
  2) PM видит все таски по своим проектам
  3) PME (или, проще - все другие польз-ли) - видит те активные таски, где он есть в Assignee
  */

  declare @EmpID int
  declare @Status int
  set @EmpID = [dbo].[DEF_EMPLOYEE](@UserID)

  declare @DepT table([ID] int primary key clustered)
  if [dbo].[DEF_USERINGROUP1](@UserID,'ADM') = 1
  begin
    insert into @res ([ID])
      select [a].[ID]
      from [dbo].[PM_TASK] [a] with(nolock)
    return
  end
  if [dbo].[DEF_USERINGROUP1](@UserID,'DH&VICE') = 1
  begin
    insert into @DepT
      select distinct [ID]
      from [dbo].[COM_ACCESS_DEPARTMENTS](@UserID,@Mode,@Date)

    insert into @res ([ID])
      select [a].[ID]
      from [dbo].[PM_TASK] [a] with(nolock)
      where [a].[DEPID] in (select [ID] from @DepT)

    merge @res [a]
    using
      (
      select [a].[ID]
      from [dbo].[PM_TASK] [a] with(nolock)
      where [a].[RESPDEP] in (select [ID] from @DepT)
      ) [b] on [a].[ID]=[b].[ID]
    when not matched then
      insert ([ID]) values ([b].[ID]);
  end
  if [dbo].[DEF_USERINGROUP1](@UserID,'PM') = 1
  begin
    merge @res [a]
    using
      (
       select distinct [a].[ID]
       from [dbo].[PM_TASK] [a] with(nolock)
        left join [dbo].[PM_PROJECT] [b] with(nolock) on [b].[ID]=[a].[PROJID]
       where [a].[PROJID] in (select [ID] from dbo.PM_PROJECTS_ACCESS_TAB(@UserID,1,@Date))
         and [b].[PROJLEAD] = @EmpID
      ) [b] on [a].[ID]=[b].[ID]
    when not matched then
      insert ([ID]) values ([b].[ID]);

     /*KB2117 либо проект свой .. */

    merge @res [a]
    using
      (
      select distinct [a].[ID]
      from [dbo].[PM_TASK] [a] with(nolock)
        left join [dbo].[PM_PROJECT] [b] with(nolock) on [b].[ID]=[a].[PROJID]
      where /* KB4605  A.PROJID in (select ID from dbo.PM_PROJECTS_ACCESS_TAB(@aUserID,1,@aDate))
       and*/ exists (select [K].[ID] from [dbo].[PM_PROJECT_COLEADERS] [K] with(nolock) where [K].[VNESHID]=[a].[PROJID] and [K].[EMPLID]=@EmpID)
       /*либо Co-leader в проекте */
      ) [b] on [a].[ID]=[b].[ID]
    when not matched then
      insert ([ID]) values ([b].[ID]);

    /*KB2117 ... либо PM указан в одной из родительских задач */
    merge @res [a]
    using
      (
      select [a].[ID]
      from [dbo].[PM_TASK] [a] with(nolock)
      where [a].[PROJID] in (select [ID] from [dbo].[PM_PROJECTS_ACCESS_TAB](@UserID,1,@Date))
        and exists (select [H].[ID]
                    from [dbo].[PM_TASK_ASSIGNEE] [H] with(nolock)
                    where [H].[EMPLID]=@EmpID
                      and [H].[VNESHID] in (select [ID] from [dbo].[PM_GET_PARENT_TASKS]([a].[ID],0))
            )
      ) [b] on [a].[ID]=[b].[ID]
    when not matched then
      insert ([ID]) values ([b].[ID]);

     /*KB4605*/
    merge @res [a]
    using
      (
      select distinct [b].[ID]
      from [dbo].[PM_TASK_ASSIGNEE] [a] with(nolock)
        cross apply [dbo].[PM_GET_CHILD_TASKS]([a].[VNESHID],123) [b]
      where [a].[EMPLID]=@EmpID
      ) [b] on [a].[ID]=[b].[ID]
    when not matched then
      insert ([ID]) values ([b].[ID]);
  end

  --#region KB5243: The user should be able to see tasks that they have created themselves.
  merge @res [a]
  using
    (
    select distinct [a].[ID]
    from [dbo].[PM_TASK] [a] with(nolock)
    where [a].[S_CR]=@UserID
    ) [b] on [a].[ID]=[b].[ID]
  when not matched then
    insert ([ID]) values ([b].[ID]);
  --#endregion

  merge @res [a]
  using
    (
    select distinct [a].[VNESHID] [ID]
    from [dbo].[PM_TASK_ASSIGNEE] [a] with(nolock)
      left join [dbo].[PM_TASK]    [b] with(nolock) on [b].[ID]=[a].[VNESHID]
      left join [dbo].[PM_PROJECT] [c] with(nolock) on [c].[ID]=[b].[PROJID]
    where 
      -- A.EMPLID=@EmpID  --was before KB4237
          ([a].[EMPLID]=@EmpID or [b].[S_CR]=@UserID) /* KB4237 ...или TASK создаанн пользователем */ 
      and [c].[S_S] in (2130048 /*active*/)
    ) [b] on [a].[ID]=[b].[ID]
  when not matched then
    insert ([ID]) values ([b].[ID]);

  if @Mode = 10
  begin
      /*добавляются родительские задачи чтобы их можно было видеть KB1781*/
    merge @res [a]
    using
      (
      select distinct [d].[ID]
      from [dbo].[PM_TASK_ASSIGNEE] [a] with(nolock)
        left join [dbo].[PM_TASK]    [b] with(nolock) on [b].[ID]=[a].[VNESHID]
        left join [dbo].[PM_PROJECT] [c] with(nolock) on [c].[ID]=[b].[PROJID]
        cross apply [dbo].[PM_GET_PARENT_TASKS]([b].[ID],0) [d]
      where [c].[S_S] in (2130048 /*active*/)
        --  [a].[EMPLID] = @EmpID
        and ([a].[EMPLID]=@EmpID or [b].[S_CR]=@UserID) /* KB4237 ...или TASK создаанн пользователем */ 
      ) [b] on [a].[ID]=[b].[ID]
    when not matched then
      insert ([ID]) values ([b].[ID]);
  end
  return
end