-- KB5391:2025-04-28: Using [PM_TASK_TIME].[MINUTES] if it available.
-- KB4946:2024-09-10: Added condition [DUEDATE]<=[CALC_DUEDATE].
-- KB4777:2024-05-24: Updated [Labor Estimate] filling. Added optional parameters.
CREATE PROCEDURE [dbo].[PM_CHECK_KB3954] @UserID int, @aMode int = 0, @RecipientEmplID int = 0, @Options nvarchar(max)=null
AS
BEGIN
  /*KB3954*/
  set nocount on

  declare @OptionsT table ([OPTION] nvarchar(max))
  insert into @OptionsT select [ITEM] from [dbo].[COM_STR2TABLE_STR](@Options)
  declare @now datetime = GETDATE()
  declare @nowDate date = CAST(@now as date)
  declare @NoSend int = 0
  declare @LaborDone int = 0
  declare @LaborExistsUntilDue int = 0
  declare @ForceSend int = 0

  if exists(select * from @OptionsT where [OPTION] like 'NoSend')              set @NoSend = 1
  if exists(select * from @OptionsT where [OPTION] like 'LaborDone')           set @LaborDone = 1
  if exists(select * from @OptionsT where [OPTION] like 'ForceSend')           set @ForceSend = 1
  if exists(select * from @OptionsT where [OPTION] like 'LaborExistsUntilDue') set @LaborExistsUntilDue = 1

  --select @NoSend[@NoSend],@LaborDone[@LaborDone],@ForceSend [@ForceSend],@LaborExistsUntilDue[@LaborExistsUntilDue]
  --return

  if @RecipientEmplID=0 and @ForceSend=0 and @NoSend = 0
    if datepart(hour,@now) < 7 or datepart(hour,@now) > 10 or dbo.COM_IS_WORKDAY(@nowDate,1) <> 1
    begin
      set nocount off
      return
    end

  if @RecipientEmplID=0 and @ForceSend=0 and @NoSend = 0
    if exists (select * from PM_KB3824_NOTIFICATION_DATES where NTYPE = 3954 /*KB3954*/ and LASTDD >= @nowDate)
    begin
      set nocount off
      return
    end

  declare @TasksT table([TASKID] int,unique clustered ([TASKID]))
  insert into @TasksT
    select distinct
       [a].[ID]
    from [dbo].[PM_TASK] [a] with(nolock)
    where [a].[JIRA_ID] is null
      and isnull([a].[EXCLFROMPLAN],0) <> 1
      and [a].[S_S] = 1
      and [a].[DUEDATE] is not null
      and [a].[LABOR_EST] > 0
      --and [a].[ID]=14152

  declare @ChildTasksT table([TASKID] int,[CHILDTASKID] int
    ,index [IX-1] clustered ([TASKID])
    ,index [IX-2] ([CHILDTASKID])
    ,index [IX-3] ([TASKID],[CHILDTASKID]))
  insert into @ChildTasksT
    select
       [a].[TASKID]
      ,[b].[ID]
    from @TasksT [a]
      cross apply [dbo].[PM_GET_CHILD_TASKS]([a].[TASKID],123) [b]

  declare @TaskAssigneeT table([TASKID] int,[EMPLID] int
    ,index [IX-1] clustered ([TASKID])
    ,index [IX-2] ([EMPLID])
    ,index [IX-3] ([TASKID],[EMPLID]))
  insert into @TaskAssigneeT
    select distinct
      [a].[TASKID],[c].[EMPLID]
    from @TasksT [a]
      inner join @ChildTasksT [b] on [b].[TASKID]=[a].[TASKID]
      inner join [dbo].[PM_TASK_ASSIGNEE] [c] with(nolock) on [c].[VNESHID]=[b].[CHILDTASKID]

  declare @TaskTimeG table([TASKID] int,[LABOR_DONE] float
    ,index [IX-1] clustered ([TASKID]))
  insert into @TaskTimeG
    select
       [a].[TASKID]
      ,(select sum(case when [b].[MINUTES] is not null then [b].[MINUTES] else round([b].[MHOUR]*60,0) end)/60.0
        from PM_TASK_TIME [b] with(nolock)
        where [b].EMPLID in (select [g].[EMPLID]      from @TaskAssigneeT [g] where [g].[TASKID]=[a].[TASKID])
          and [b].TASKID in (select [g].[CHILDTASKID] from @ChildTasksT   [g] where [g].[TASKID]=[a].[TASKID]))
    from @TasksT [a]

  declare @EmplTimeG table([TASKID] int,[LABOR_EXISTSUNTILDUE] float,unique clustered ([TASKID]));
  with [T]
  as
    (
    select
       [a].[TASKID]
      ,[dbo].[COM_WORK_MINUTS7](@now,dateadd(day,1,cast([b].[DUEDATE] as date)),[c].[EMPLID])/60.0 as RES
    from @TasksT [a]
      inner join [dbo].[PM_TASK] [b] with(nolock) on [b].[ID]=[a].[TASKID]
      inner join @TaskAssigneeT [c] on [c].[TASKID]=[a].[TASKID]
    )
  insert into @EmplTimeG
    select
       [a].[TASKID]
      ,sum([a].[RES]) [LABOR_EXISTSUNTILDUE]
    from [T] [a]
    group by [a].[TASKID]

  declare @tasks table (ID int, DUE datetime, LABOR_EST decimal(10,2), LABOR_DONE decimal(10,2), LABOR_EXISTSUNTILDUE decimal(10,2)
    ,[CALC_DUEDATE] date
    ,index [IX-1] ([ID]));
  with [T] as
    (
    select B.ID
          ,B.DUEDATE
          ,B.LABOR_EST
          ,[c].[LABOR_DONE]
          ,[d].[LABOR_EXISTSUNTILDUE]
          ,[dbo].[COM_WD_DATEADD](@nowDate,ceiling((B.LABOR_EST-isnull([c].[LABOR_DONE],0))/8.0) - 1,1,0) [CALC_DUEDATE]
    from @TasksT [a]
      inner join PM_TASK B with(nolock) on [B].[ID]=[a].[TASKID]
      left  join @TaskTimeG [c] on [c].[TASKID]=[a].[TASKID]
      left  join @EmplTimeG [d] on [d].[TASKID]=[a].[TASKID]
    )
  insert into @tasks (ID,DUE,LABOR_EST,LABOR_DONE, LABOR_EXISTSUNTILDUE,[CALC_DUEDATE])
    select ID,[DUEDATE],LABOR_EST,LABOR_DONE,LABOR_EXISTSUNTILDUE,[CALC_DUEDATE]
    from [T] M
    where LABOR_EST-isnull(LABOR_DONE,0) > isnull(LABOR_EXISTSUNTILDUE,0)
      and LABOR_EST-isnull(LABOR_DONE,0) > 0
      and isnull(LABOR_EXISTSUNTILDUE,0) >= 0
      and [DUEDATE]<=[CALC_DUEDATE]

  /*
  insert into @tasks (ID,DUE,LABOR_EST,LABOR_DONE, LABOR_EXISTSUNTILDUE)
    select ID,DUEDATE,LABOR_EST,LABOR_DONE,LABOR_EXISTSUNTILDUE
    from (
    select B.ID
          ,B.DUEDATE
          ,B.LABOR_EST
          ,(select sum(D.MHOUR) 
              from PM_TASK_TIME D with(nolock) 
              where D.EMPLID in (select G.EMPLID from PM_TASK_ASSIGNEE G with(nolock) where G.VNESHID in (select ID from dbo.PM_GET_CHILD_TASKS(B.ID,123)))
                and D.TASKID in (select ID from dbo.PM_GET_CHILD_TASKS(B.ID,123))
            ) as LABOR_DONE              
           ,( select sum(RES) from (
               select dbo.COM_WORK_MINUTS7(@now,dateadd(day,1,cast(B.DUEDATE as date)),G.ID) / 60 as RES 
               from COM_EMPLOYEE G with(nolock)
               where G.ID in (select G.EMPLID from PM_TASK_ASSIGNEE G with(nolock) where G.VNESHID in (select ID from dbo.PM_GET_CHILD_TASKS(B.ID,123))) 
            ) M
           ) as LABOR_EXISTSUNTILDUE  
    from PM_TASK B with(nolock) 
    where B.JIRA_ID is null
      and isnull(B.EXCLFROMPLAN,0) <> 1
      and B.S_S = 1
      and B.DUEDATE is not null
      and B.LABOR_EST > 0
    ) M
    where LABOR_EST-isnull(LABOR_DONE,0) > isnull(LABOR_EXISTSUNTILDUE,0)
      and LABOR_EST-isnull(LABOR_DONE,0) > 0  
      and isnull(LABOR_EXISTSUNTILDUE,0) >= 0
  */

  --select * from @tasks order by [ID]

  /*исполнители*/
  declare @recipients table (TASKID int, EMPLID int
    ,index [IX-1] ([TASKID])
    ,index [IX-2] ([EMPLID]))
  insert into @recipients (TASKID, EMPLID)
    select distinct A.VNESHID,A.EMPLID
    from PM_TASK_ASSIGNEE A with(nolock)
    where A.VNESHID in (select ID from @tasks)

  /*руководители отделов 
    кстати какие "руководители"?
    руководители отделов исполнителей (а если у задачи нет исполнителей?) или руководители responsible department задачи?
    сделал пока по второму варианту
  */
  insert into @recipients (TASKID, EMPLID)
    select A.TASKID, D.ID
    from @recipients A
      left join PM_TASK B with(nolock) on B.ID = A.TASKID
      left join COM_EMPLOYEE D with(nolock) on D.DEPID = B.RESPDEP and D.ROLEINDEP in (100)
    where D.ID is not null

  declare @subj nvarchar(max) = 'Due Dates are exceeding'
  declare @empl int
  declare @mess nvarchar(max) = ''

  declare cur cursor local read_only for select distinct EMPLID from @recipients where EMPLID <> 1
  open cur
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM cur INTO @empl;
    IF @@FETCH_STATUS<>0 BREAK;

    set @mess = '<p style="font-family: Arial, Helvetica, sans-serif;font-size: smaller;">Dear All,<br>'

      /*set @mess = @mess + cast(@empl as nvarchar(50))+'<br>'
      set @subj = 'Due Dates are exceeding '+ cast(@empl as nvarchar(50))*/

    set @mess = @mess +
     'Please find below the information about Tasks which Due Dates could be exceeded according to Labor Estimate Hours quantity<br><br>
     <table cellspacing = "0" border="1" bordercolor="#134a8f" style="padding: 0px; margin: 0px; border-collapse: collapse; border-spacing: 0px;width:1000px">
      <style type="text/css">
          .header
            {
            padding: 0px 5px 0px 5px; margin: 0px; border: 1px solid #134a8f;
            color: white;
            background-color: #134a8f;
            white-space: nowrap;
            }
          .value
            {
            padding: 0px 5px 0px 5px; margin: 0px; border: 1px solid #134a8f;
            }
          .employee
            {
            padding: 0px 5px 0px 5px; margin: 0px; border: 1px solid #134a8f;
            white-space: nowrap;
            }
          .float
            {
            padding: 0px 5px 0px 5px; margin: 0px; border: 1px solid #134a8f;
            white-space: nowrap;
            text-align: right;
            }
          .date
            {
            padding: 0px 5px 0px 5px; margin: 0px; border: 1px solid #134a8f;
            white-space: nowrap;
            text-align: center;
            }
      </style>
      <tr>
        <td class="header">Task</td>
        <td class="header" style="width: 10%">Employee</td>
        <td class="header" style="width: 1%">Due Date</td>
        <td class="header" style="width: 1%">Labor Estimate(h)</td>
        <td class="header" style="width: 1%">Calc. Due Date</td>
        %LaborDone%
        %LaborExistsUntilDue%
      </tr>'

    if @LaborDone = 1           set @mess = replace(@mess,'%LaborDone%','<td class="header" style="width: 1%">Labor Done(h)</td>')                       else set @mess = replace(@mess,'%LaborDone%','')
    if @LaborExistsUntilDue = 1 set @mess = replace(@mess,'%LaborExistsUntilDue%','<td class="header" style="width: 1%">Labor Exists Until Due(h)</td>') else set @mess = replace(@mess,'%LaborExistsUntilDue%','')

    declare @s  nvarchar(max) = ''
    declare @cou int = 0

    select @cou = @cou + 1
            /*,@s = @s + '<tr><td>'+isnull(A.SUBJ,'NA')+'</td><td>'+isnull(F.NAME,'')+'</td><td>'+convert(varchar,A.DUEDATE,104)+'</td><td>'+cast(A.LABOR_EST as nvarchar(20))+'</td><td></td></tr>'*/
            /*KB4137*/
            ,@s = @s + '<tr>
                          <td class="value"><a href="a2l:\\Link=doc.pm_task.' + convert(varchar,A.ID) +'">'+isnull(A.SUBJ,'NA')+'</a></td>
                          <td class="employee">'+isnull(F.NAME,'')+'</td>
                          <td class="date">'+convert(varchar,A.DUEDATE,104)+'</td>
                          <td class="float">'+cast(A.LABOR_EST as nvarchar(20))+'</td>
                          <td class="date">'+isnull(convert(varchar,[c].[CALC_DUEDATE],104),'')+'</td>' +
                          (case when @LaborDone = 1           then '<td class="float">'+isnull(cast([c].[LABOR_DONE] as nvarchar(max)),'')+'</td>' else '' end) +
                          (case when @LaborExistsUntilDue = 1 then '<td class="float">'+isnull(cast([c].[LABOR_EXISTSUNTILDUE] as nvarchar(max)),'')+'</td>' else '' end) +
                        '</tr>'
    from PM_TASK A with(nolock)
      left join PM_TASK_ASSIGNEE B with(nolock) on B.VNESHID = A.ID
      left join COM_EMPLOYEE F with(nolock) on F.ID = B.EMPLID
      left join @tasks  [c] on [c].[ID]=[A].[ID]
    where A.ID in (select TASKID from @recipients where EMPLID = @empl)

    set @mess = @mess + @s +
    '</table><br>
     Please do not answer this e-mail.<br>
     Production Database</p>'

    if @NoSend = 0
      if @cou > 0
      begin
        if @RecipientEmplID <> 0
        begin
          exec MSG_SEND_TOEMPLOYEE @UserID, @RecipientEmplID, @subj, @mess
        end else
          exec MSG_SEND_TOEMPLOYEE @UserID, @empl, @subj, @mess 
      end
  end
  close cur;
  deallocate cur;

  if @NoSend = 0
  begin
    update PM_KB3824_NOTIFICATION_DATES set LASTDD = @nowDate where NTYPE = 3954  /*KB3954*/
    if @@rowcount = 0
      insert into PM_KB3824_NOTIFICATION_DATES (NTYPE,LASTDD) values (3954,@nowDate)
  end else
    select @mess
  set nocount off 
end